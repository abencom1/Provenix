#!/usr/bin/env node
/**
 * Asserts the structural fact/opinion separation that migration 007 (see
 * provenix_excipient_personalization_spec_v0.5.md §10.5) is supposed to
 * guarantee, against the LIVE database -- not just by reading the SQL.
 * Requires migration 007 to already be applied.
 *
 * Usage: npx tsx scripts/testExcipientLayerBoundaries.ts
 * Requires SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in .env.
 *
 * Coverage:
 *   1. contested_excipients / contextual_sources have no risk-implying
 *      column, checked against PostgREST's own OpenAPI schema description
 *      (GET /rest/v1/) -- no raw Postgres/information_schema access needed.
 *   2. methodology_changelog rejects UPDATE and DELETE at the database
 *      level, checked by actually attempting both against a real row.
 *
 * NOT covered here, and why: whether product_excipient_regulatory_flags
 * joins ONLY product_excipients + excipient_regulatory_actions can't be
 * checked through the standard Supabase REST/JS client -- that needs
 * information_schema.view_table_usage or pg_depend, which PostgREST doesn't
 * expose, and this repo has no direct Postgres/`pg` driver connection
 * configured (see provenix_migration_007_excipient_layer.sql's own note on
 * this). The view is a 15-line, 2-table join -- verify it by reading that
 * file's "Scoring view" section directly until a real DB connection exists
 * to automate it. Don't add a new credential/dependency just for this one
 * check.
 *
 * Also not covered: wiring this into CI. There's no .github/workflows in
 * this repo yet -- this script is ready to be called from one whenever that
 * exists, but nothing calls it automatically today.
 */
import "dotenv/config";
import { createClient } from "@supabase/supabase-js";

const supabaseUrl = process.env.SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !serviceRoleKey) {
  throw new Error("SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set in .env");
}

const supabase = createClient(supabaseUrl, serviceRoleKey);

const RISK_IMPLYING_WORDS = [
  "risk",
  "severity",
  "concern",
  "warning",
  "caution",
  "danger",
  "hazard",
];

let failures = 0;

function fail(message: string) {
  failures += 1;
  console.error(`FAIL: ${message}`);
}

function pass(message: string) {
  console.log(`PASS: ${message}`);
}

async function checkNoRiskColumns(tableName: string) {
  const res = await fetch(`${supabaseUrl}/rest/v1/`, {
    headers: { apikey: serviceRoleKey!, Authorization: `Bearer ${serviceRoleKey}` },
  });
  if (!res.ok) {
    fail(`could not fetch PostgREST schema description (${res.status}) to check ${tableName}`);
    return;
  }
  const spec = (await res.json()) as {
    definitions?: Record<string, { properties?: Record<string, unknown> }>;
  };
  const columns = Object.keys(spec.definitions?.[tableName]?.properties ?? {});
  if (columns.length === 0) {
    fail(`${tableName} not found in schema (or has no columns) -- is migration 007 applied?`);
    return;
  }
  const offending = columns.filter((col) =>
    RISK_IMPLYING_WORDS.some((word) => col.toLowerCase().includes(word)),
  );
  if (offending.length > 0) {
    fail(`${tableName} has risk-implying column(s): ${offending.join(", ")} -- see §9.3/§10.5`);
  } else {
    pass(`${tableName} has no risk/severity/concern column (${columns.length} columns checked)`);
  }
}

async function checkMethodologyChangelogAppendOnly() {
  let { data: version } = await supabase
    .from("methodology_versions")
    .select("id")
    .limit(1)
    .maybeSingle();

  if (!version) {
    const { data: created, error } = await supabase
      .from("methodology_versions")
      .insert({ version_label: "boundary_test_v0", description: "created by testExcipientLayerBoundaries.ts" })
      .select("id")
      .single();
    if (error) {
      fail(`could not create a methodology_versions row to test against: ${error.message}`);
      return;
    }
    version = created;
  }

  const { data: row, error: insertError } = await supabase
    .from("methodology_changelog")
    .insert({
      methodology_version_id: version.id,
      entity_type: "test",
      change_type: "added",
      summary: "boundary-test row from testExcipientLayerBoundaries.ts -- expected to persist permanently, that's the point of testing append-only",
    })
    .select("id")
    .single();

  if (insertError || !row) {
    fail(`could not insert a methodology_changelog row to test against: ${insertError?.message}`);
    return;
  }

  const { error: updateError } = await supabase
    .from("methodology_changelog")
    .update({ summary: "attempted mutation" })
    .eq("id", row.id);
  if (updateError) {
    pass("methodology_changelog rejects UPDATE");
  } else {
    fail("methodology_changelog allowed an UPDATE -- append-only trigger is missing or broken");
  }

  const { error: deleteError } = await supabase
    .from("methodology_changelog")
    .delete()
    .eq("id", row.id);
  if (deleteError) {
    pass("methodology_changelog rejects DELETE");
  } else {
    fail("methodology_changelog allowed a DELETE -- append-only trigger is missing or broken");
  }
}

async function main() {
  await checkNoRiskColumns("contested_excipients");
  await checkNoRiskColumns("contextual_sources");
  await checkMethodologyChangelogAppendOnly();

  console.log(
    "\nNOT automated -- verify by reading provenix_migration_007_excipient_layer.sql's " +
      "'Scoring view' section: product_excipient_regulatory_flags must join ONLY " +
      "product_excipients + excipient_regulatory_actions, nothing else.",
  );

  if (failures > 0) {
    console.error(`\n${failures} boundary check(s) failed.`);
    process.exit(1);
  }
  console.log("\nAll automated boundary checks passed.");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
