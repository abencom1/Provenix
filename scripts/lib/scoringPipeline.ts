/**
 * Shared fetch/score/insert pipeline used by scripts/runScoring.ts and
 * scripts/recordMethodologyChangelogEntry.ts. Deliberately has no top-level
 * executable code (no main(), nothing runs on import) — it exists purely so
 * both scripts can share one implementation instead of two copies that
 * silently drift apart.
 *
 * Requires SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in .env.
 */
import { createClient } from "@supabase/supabase-js";
import { scoreProductV1 } from "../../src/lib/scoring/scoreProductV1";
import type {
  AttributionConfidence,
  IngredientListShape,
  LabTestingTier,
  ProductScoringInput,
  TrustScoreResultV1,
} from "../../src/lib/scoring/types";

const supabaseUrl = process.env.SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !serviceRoleKey) {
  throw new Error("SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set in .env");
}

export const supabase = createClient(supabaseUrl, serviceRoleKey);

export type SeedProduct = {
  id: string;
  brand_id: string;
  ingredient_list: IngredientListShape | null;
};

let cachedCurrentMethodologyVersionId: string | null = null;

// Migration 009: exactly one methodology_versions row has is_current = true.
// Cached per process run -- this script never changes which version is
// current mid-run, so one lookup is enough.
export async function getCurrentMethodologyVersionId(): Promise<string> {
  if (cachedCurrentMethodologyVersionId) return cachedCurrentMethodologyVersionId;
  const { data, error } = await supabase
    .from("methodology_versions")
    .select("id")
    .eq("is_current", true)
    .single();
  if (error || !data) {
    throw new Error(`no current methodology_versions row found: ${error?.message}`);
  }
  cachedCurrentMethodologyVersionId = data.id;
  return data.id;
}

export async function buildScoringInput(product: SeedProduct): Promise<ProductScoringInput> {
  const { data: attribution } = await supabase
    .from("manufacturer_attributions")
    .select("id, confidence")
    .eq("product_id", product.id)
    .eq("is_current", true)
    .maybeSingle();

  let facilityIds: string[] = [];
  if (attribution) {
    const { data: facilityLinks } = await supabase
      .from("manufacturer_attribution_facilities")
      .select("facility_id")
      .eq("attribution_id", attribution.id);
    facilityIds = (facilityLinks ?? []).map((f) => f.facility_id);
  }
  const facilityCount = facilityIds.length;

  const { data: recalls } = await supabase
    .from("recalls")
    .select("classification, status")
    .or(`product_id.eq.${product.id},brand_id.eq.${product.brand_id}`);

  const { data: inspections } =
    facilityIds.length > 0
      ? await supabase
          .from("inspection_classifications")
          .select("classification")
          .in("facility_id", facilityIds)
      : { data: [] as { classification: string }[] };

  const regulatoryActionsOr =
    facilityIds.length > 0
      ? `brand_id.eq.${product.brand_id},facility_id.in.(${facilityIds.join(",")})`
      : `brand_id.eq.${product.brand_id}`;
  const { data: regulatoryActions } = await supabase
    .from("regulatory_actions")
    .select("status")
    .or(regulatoryActionsOr);

  const warningLettersOr =
    facilityIds.length > 0
      ? `brand_id.eq.${product.brand_id},facility_id.in.(${facilityIds.join(",")})`
      : `brand_id.eq.${product.brand_id}`;
  const { data: warningLetters } = await supabase
    .from("warning_letters")
    .select("status")
    .or(warningLettersOr);

  const { data: ndiFlags } = await supabase
    .from("ndi_flags")
    .select("expected_notification, notification_found")
    .eq("product_id", product.id);

  // Reads product_excipient_regulatory_flags (migration 007), not the raw
  // excipient_regulatory_actions table directly -- the view is the one
  // sanctioned path from the excipient layer into scoring (see the v0.5
  // spec's §10.5). No regulator filter here or in the view itself: every
  // row returned is already scoreable by construction.
  const { data: excipientRegulatoryActions } = await supabase
    .from("product_excipient_regulatory_flags")
    .select("status")
    .eq("product_id", product.id);

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
      inspectionClassifications: (inspections ?? []).map((i) => ({
        classification: i.classification as "NAI" | "VAI" | "OAI",
      })),
      regulatoryActions: (regulatoryActions ?? []).map((a) => ({
        status: a.status as "active" | "closed",
      })),
      warningLetters: (warningLetters ?? []).map((w) => ({
        status: w.status as "active" | "closed",
      })),
      ndiFlags: (ndiFlags ?? []).map((f) => ({
        expectedNotification: f.expected_notification,
        notificationFound: f.notification_found,
      })),
      excipientRegulatoryActions: (excipientRegulatoryActions ?? []).map((a) => ({
        status: a.status as "active" | "closed",
      })),
    },
    adverseEvents: { reportCount: adverseEvents?.report_count ?? null },
    ingredientTransparency: { ingredientList: product.ingredient_list },
    testingQuality: { tier: (labTesting?.tier as LabTestingTier) ?? null },
    certifications: { certifications: certifications ?? null },
  };
}

// Scores one product and inserts its trust_scores/trust_subscores rows,
// stamped with the current methodology version (migration 009 — "scores
// already carry their methodology version" is enforced by trust_scores.
// methodology_version_id being NOT NULL, not just by this function
// remembering to set it).
export async function scoreAndRecordProduct(product: SeedProduct): Promise<TrustScoreResultV1> {
  const input = await buildScoringInput(product);
  const result = scoreProductV1(input);
  const methodologyVersionId = await getCurrentMethodologyVersionId();

  const { data: trustScore, error: trustScoreError } = await supabase
    .from("trust_scores")
    .insert({
      product_id: product.id,
      overall_score: result.overallScore,
      is_scorable: result.isScorable,
      explanation: result.explanation,
      methodology_version_id: methodologyVersionId,
    })
    .select("id")
    .single();

  if (trustScoreError) throw trustScoreError;

  const subscoreRows = result.subscores.map((s) => ({
    trust_score_id: trustScore.id,
    subscore_type: s.type,
    value: s.value,
  }));

  const { error: subscoreError } = await supabase.from("trust_subscores").insert(subscoreRows);
  if (subscoreError) throw subscoreError;

  return result;
}

export async function getSeedProducts(): Promise<SeedProduct[]> {
  const { data: products, error: productsError } = await supabase
    .from("products")
    .select("id, brand_id, ingredient_list")
    .eq("is_seed_sku", true);

  if (productsError) throw productsError;
  return (products ?? []) as SeedProduct[];
}
