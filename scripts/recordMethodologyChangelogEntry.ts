#!/usr/bin/env node
/**
 * Records one methodology_changelog entry, with a REAL scores_affected_count
 * rather than a guessed one — computed by snapshotting every seed product's
 * latest trust_scores row, re-running scoring, and counting how many
 * differ. Re-running scoring also leaves a fresh trust_scores row on record
 * for every product, which is the right thing to do after any change that
 * could plausibly affect scores anyway.
 *
 * Why this has to work this way: the penalty/weight formulas that determine
 * whether a score "moved" live in scoreProductV1.ts (TypeScript), not in
 * the database — there is no way to compute this count from SQL alone. And
 * because methodology_changelog is append-only (migration 007's trigger
 * rejects UPDATE), the count has to be known BEFORE the row is inserted,
 * not filled in afterward.
 *
 * Usage:
 *   npx tsx scripts/recordMethodologyChangelogEntry.ts \
 *     --entity-type="scoring_penalty_type" \
 *     --change-type="added" \
 *     --summary="Excipient regulatory flags added as a new regulatory_compliance penalty type (migrations 007/008)." \
 *     [--entity-id="<uuid>"]
 *
 * entity_type / change_type / summary are required. entity_id is optional —
 * some changelog entries describe a schema-level change, not one row (see
 * migration 007's own comment on methodology_changelog.entity_id).
 *
 * Requires SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in .env.
 */
import "dotenv/config";
import {
  getCurrentMethodologyVersionId,
  getSeedProducts,
  scoreAndRecordProduct,
  supabase,
} from "./lib/scoringPipeline";

function parseArg(name: string): string | undefined {
  const prefix = `--${name}=`;
  const arg = process.argv.find((a: string) => a.startsWith(prefix));
  return arg?.slice(prefix.length);
}

async function main() {
  const entityType = parseArg("entity-type");
  const changeType = parseArg("change-type");
  const summary = parseArg("summary");
  const entityId = parseArg("entity-id");

  if (!entityType || !changeType || !summary) {
    console.error(
      "Usage: npx tsx scripts/recordMethodologyChangelogEntry.ts " +
        '--entity-type=<text> --change-type=<added|removed|modified> --summary="<text>" [--entity-id=<uuid>]',
    );
    process.exit(1);
  }

  const products = await getSeedProducts();
  if (products.length === 0) {
    console.log("No seed products found — nothing to compare, recording with scores_affected_count=0.");
  }

  const before = new Map<string, { overallScore: number | null; isScorable: boolean }>();
  for (const product of products) {
    const { data } = await supabase
      .from("trust_scores")
      .select("overall_score, is_scorable")
      .eq("product_id", product.id)
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();
    before.set(product.id, {
      overallScore: data?.overall_score ?? null,
      isScorable: data?.is_scorable ?? false,
    });
  }

  let affectedCount = 0;
  for (const product of products) {
    const result = await scoreAndRecordProduct(product);
    const prior = before.get(product.id);
    const changed =
      !prior || prior.overallScore !== result.overallScore || prior.isScorable !== result.isScorable;
    if (changed) affectedCount += 1;
    console.log(
      `${product.id}: ${prior?.overallScore ?? "n/a"} -> ${result.overallScore ?? "not scorable"}` +
        (changed ? "  [CHANGED]" : ""),
    );
  }

  const methodologyVersionId = await getCurrentMethodologyVersionId();

  const { error } = await supabase.from("methodology_changelog").insert({
    methodology_version_id: methodologyVersionId,
    entity_type: entityType,
    entity_id: entityId ?? null,
    change_type: changeType,
    summary,
    scores_affected_count: affectedCount,
  });

  if (error) throw error;

  console.log(`\nRecorded changelog entry. scores_affected_count = ${affectedCount}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
