#!/usr/bin/env node
/**
 * Exercises the dose-reality gate (migration 008,
 * provenix_excipient_personalization_spec_v0.5.md Build Prompt 3.2) against
 * the LIVE database. Requires migration 008 to already be applied.
 *
 * Usage: npx tsx scripts/testDoseRealityGate.ts
 * Requires SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in .env.
 *
 * Coverage:
 *   1. excipient_regulatory_actions rejects a direct insert with no
 *      dose_reality_check_id (the NOT NULL constraint added in 008).
 *   2. publish_excipient_regulatory_action_proposal() rejects a proposal
 *      that isn't in 'approved' state.
 *   3. The full draft -> pending -> approved -> published path produces a
 *      live excipient_regulatory_actions row AND a methodology_changelog
 *      entry, in one call.
 *   4. A rejected proposal persists and stays queryable (not deleted).
 *
 * All test rows this script creates are cleaned up at the end EXCEPT the
 * methodology_changelog entry from check 3, which can't be -- that table is
 * append-only by design (migration 007). Same accepted tradeoff as
 * testExcipientLayerBoundaries.ts.
 */
import "dotenv/config";
import { createClient } from "@supabase/supabase-js";

const supabaseUrl = process.env.SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !serviceRoleKey) {
  throw new Error("SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set in .env");
}

const supabase = createClient(supabaseUrl, serviceRoleKey);

let failures = 0;
function fail(message: string) {
  failures += 1;
  console.error(`FAIL: ${message}`);
}
function pass(message: string) {
  console.log(`PASS: ${message}`);
}

async function main() {
  const { data: excipient, error: excipientError } = await supabase
    .from("excipients")
    .insert({ name: `Boundary test excipient ${Date.now()}` })
    .select("id")
    .single();
  if (excipientError || !excipient) throw new Error(`setup failed: ${excipientError?.message}`);

  let { data: version } = await supabase
    .from("methodology_versions")
    .select("id")
    .limit(1)
    .maybeSingle();
  if (!version) {
    const { data: created, error } = await supabase
      .from("methodology_versions")
      .insert({ version_label: "dose_reality_gate_test_v0" })
      .select("id")
      .single();
    if (error || !created) throw new Error(`setup failed: ${error?.message}`);
    version = created;
  }

  // 1. Direct insert with no dose_reality_check_id must fail.
  const { error: directInsertError } = await supabase.from("excipient_regulatory_actions").insert({
    excipient_id: excipient.id,
    regulator: "FDA",
    citation_url: "https://example.gov/action",
    source: "test",
  });
  if (directInsertError) {
    pass("excipient_regulatory_actions rejects insert with no dose_reality_check_id");
  } else {
    fail("excipient_regulatory_actions allowed an insert with no dose_reality_check_id");
  }

  // 2. Publish must reject a non-approved proposal.
  const { data: draftProposal, error: draftError } = await supabase
    .from("excipient_regulatory_action_proposals")
    .insert({
      excipient_id: excipient.id,
      regulator: "EFSA",
      citation_url: "https://example.eu/action",
      source: "test",
      state: "draft",
    })
    .select("id")
    .single();
  if (draftError || !draftProposal) throw new Error(`setup failed: ${draftError?.message}`);

  const { error: publishDraftError } = await supabase.rpc(
    "publish_excipient_regulatory_action_proposal",
    { p_proposal_id: draftProposal.id, p_methodology_version_id: version.id },
  );
  if (publishDraftError) {
    pass("publish function rejects a proposal not in 'approved' state");
  } else {
    fail("publish function published a draft proposal -- gate is not enforced");
  }

  // 3. Full happy path: draft -> check -> approved -> published.
  const { data: check, error: checkError } = await supabase
    .from("dose_reality_checks")
    .insert({
      reviewer_name: "test script",
      presents_plausible_human_risk: true,
      reasoning: "test reasoning",
      exposure_figures_considered: "test exposure figures",
      supporting_evidence_source: "test source",
    })
    .select("id")
    .single();
  if (checkError || !check) throw new Error(`setup failed: ${checkError?.message}`);

  const { error: approveError } = await supabase
    .from("excipient_regulatory_action_proposals")
    .update({ dose_reality_check_id: check.id, state: "approved" })
    .eq("id", draftProposal.id);
  if (approveError) throw new Error(`setup failed: ${approveError.message}`);

  const { data: publishedId, error: publishError } = await supabase.rpc(
    "publish_excipient_regulatory_action_proposal",
    { p_proposal_id: draftProposal.id, p_methodology_version_id: version.id },
  );
  if (publishError || !publishedId) {
    fail(`publish function failed on a genuinely approved proposal: ${publishError?.message}`);
  } else {
    pass("publish function promoted an approved proposal to a live regulatory action");

    const { data: changelogRow } = await supabase
      .from("methodology_changelog")
      .select("id")
      .eq("entity_id", publishedId)
      .eq("entity_type", "excipient_regulatory_action")
      .maybeSingle();
    if (changelogRow) {
      pass("publish function wrote a matching methodology_changelog entry");
    } else {
      fail("publish function did not write a methodology_changelog entry");
    }
  }

  // 4. Rejected proposal persists and is queryable.
  const { data: rejectedProposal, error: rejectedError } = await supabase
    .from("excipient_regulatory_action_proposals")
    .insert({
      excipient_id: excipient.id,
      regulator: "TGA",
      citation_url: "https://example.au/action",
      source: "test",
      state: "rejected",
      rejection_reason: "animal data at non-physiological doses only",
    })
    .select("id")
    .single();
  if (rejectedError || !rejectedProposal) {
    fail(`could not insert a rejected proposal: ${rejectedError?.message}`);
  } else {
    const { data: found } = await supabase
      .from("excipient_regulatory_action_proposals")
      .select("state, rejection_reason")
      .eq("id", rejectedProposal.id)
      .single();
    if (found?.state === "rejected" && found.rejection_reason) {
      pass("rejected proposals persist and are queryable");
    } else {
      fail("rejected proposal did not persist as expected");
    }
  }

  // Cleanup -- everything except the changelog row, which can't be removed.
  await supabase.from("excipient_regulatory_actions").delete().eq("id", publishedId ?? "");
  await supabase.from("excipient_regulatory_action_proposals").delete().eq("excipient_id", excipient.id);
  await supabase.from("dose_reality_checks").delete().eq("id", check.id);
  await supabase.from("excipients").delete().eq("id", excipient.id);

  if (failures > 0) {
    console.error(`\n${failures} check(s) failed.`);
    process.exit(1);
  }
  console.log("\nAll dose-reality gate checks passed.");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
