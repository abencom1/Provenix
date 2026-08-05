#!/usr/bin/env node
/**
 * Runs scoreProductV1 against every seed SKU in Supabase and writes new
 * trust_scores/trust_subscores rows (one INSERT per run — scores are
 * versioned like manufacturer_attributions, not updated in place).
 *
 * Usage: npx tsx scripts/runScoring.ts
 * Requires SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in .env — the service
 * role key is required because trust_scores/trust_subscores have no public
 * write policy (see provenix_rls.sql).
 *
 * The actual fetch/score/insert logic lives in scripts/lib/scoringPipeline.ts,
 * shared with scripts/recordMethodologyChangelogEntry.ts (Build Prompt 3.3) —
 * this file is just the CLI entrypoint.
 */
import "dotenv/config";
import { getSeedProducts, scoreAndRecordProduct } from "./lib/scoringPipeline";

async function main() {
  const products = await getSeedProducts();
  if (products.length === 0) {
    console.log("No seed products found.");
    return;
  }

  for (const product of products) {
    const result = await scoreAndRecordProduct(product);
    console.log(
      `${product.id}: ${result.isScorable ? result.overallScore : "not scorable"} — ${result.explanation}`,
    );
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
