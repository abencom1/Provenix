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
 */
import "dotenv/config";
import { createClient } from "@supabase/supabase-js";
import { scoreProductV1 } from "../src/lib/scoring/scoreProductV1";
import type {
  AttributionConfidence,
  IngredientListShape,
  LabTestingTier,
  ProductScoringInput,
} from "../src/lib/scoring/types";

const supabaseUrl = process.env.SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !serviceRoleKey) {
  throw new Error("SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set in .env");
}

const supabase = createClient(supabaseUrl, serviceRoleKey);

type SeedProduct = {
  id: string;
  brand_id: string;
  ingredient_list: IngredientListShape | null;
};

async function buildScoringInput(product: SeedProduct): Promise<ProductScoringInput> {
  const { data: attribution } = await supabase
    .from("manufacturer_attributions")
    .select("id, confidence")
    .eq("product_id", product.id)
    .eq("is_current", true)
    .maybeSingle();

  let facilityCount = 0;
  if (attribution) {
    const { count } = await supabase
      .from("manufacturer_attribution_facilities")
      .select("facility_id", { count: "exact", head: true })
      .eq("attribution_id", attribution.id);
    facilityCount = count ?? 0;
  }

  const { data: recalls } = await supabase
    .from("recalls")
    .select("classification, status")
    .or(`product_id.eq.${product.id},brand_id.eq.${product.brand_id}`);

  const { data: adverseEvents } = await supabase
    .from("adverse_event_counts")
    .select("report_count")
    .or(`product_id.eq.${product.id},brand_id.eq.${product.brand_id}`)
    .order("last_refreshed", { ascending: false })
    .limit(1)
    .maybeSingle();

  const { data: labTesting } = await supabase
    .from("lab_testing")
    .select("tier")
    .eq("product_id", product.id)
    .order("last_verified", { ascending: false })
    .limit(1)
    .maybeSingle();

  const { data: certifications } = await supabase
    .from("certifications")
    .select("status")
    .eq("product_id", product.id);

  return {
    productId: product.id,
    manufacturerTransparency: {
      confidence: (attribution?.confidence as AttributionConfidence) ?? null,
      facilityCount,
    },
    regulatoryCompliance: {
      recalls: (recalls ?? []).map((r) => ({
        classification: r.classification,
        status: r.status as "active" | "closed",
      })),
    },
    adverseEvents: { reportCount: adverseEvents?.report_count ?? null },
    ingredientTransparency: { ingredientList: product.ingredient_list },
    testingQuality: { tier: (labTesting?.tier as LabTestingTier) ?? null },
    certifications: { certifications: certifications ?? null },
  };
}

async function main() {
  const { data: products, error: productsError } = await supabase
    .from("products")
    .select("id, brand_id, ingredient_list")
    .eq("is_seed_sku", true);

  if (productsError) throw productsError;
  if (!products || products.length === 0) {
    console.log("No seed products found.");
    return;
  }

  for (const product of products as SeedProduct[]) {
    const input = await buildScoringInput(product);
    const result = scoreProductV1(input);

    const { data: trustScore, error: trustScoreError } = await supabase
      .from("trust_scores")
      .insert({
        product_id: product.id,
        overall_score: result.overallScore,
        is_scorable: result.isScorable,
        explanation: result.explanation,
      })
      .select("id")
      .single();

    if (trustScoreError) throw trustScoreError;

    const subscoreRows = result.subscores.map((s) => ({
      trust_score_id: trustScore.id,
      subscore_type: s.type,
      value: s.value,
    }));

    const { error: subscoreError } = await supabase
      .from("trust_subscores")
      .insert(subscoreRows);
    if (subscoreError) throw subscoreError;

    console.log(
      `${product.id}: ${result.isScorable ? result.overallScore : "not scorable"} — ${result.explanation}`,
    );
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
