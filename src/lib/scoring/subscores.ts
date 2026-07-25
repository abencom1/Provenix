import type {
  AdverseEventsInput,
  CertificationsInput,
  IngredientTransparencyInput,
  ManufacturerTransparencyInput,
  RegulatoryComplianceInput,
  TestingQualityInput,
} from "./types";

export function scoreManufacturerTransparency(
  input: ManufacturerTransparencyInput,
): number | null {
  if (input.confidence === null) return null;
  if (input.confidence === "high") return 100;
  if (input.confidence === "low") return 30;

  // moderate: more candidate facilities means genuinely more uncertainty,
  // not just a display quirk — the score should reflect that honestly.
  const extraCandidates = Math.max(0, input.facilityCount - 1);
  return Math.max(40, 75 - extraCandidates * 5);
}

const RECALL_PENALTY: Record<string, number> = {
  "Class I": 15,
  "Class II": 8,
  "Class III": 3,
};

// Caps total penalty PER SEVERITY CLASS rather than letting it sum
// unbounded. Without this, a high-volume brand with many old, resolved
// recalls across different package sizes (several of which are the same
// underlying incident) gets driven straight to 0 — which reads as "as bad as
// an active Class I contamination," and it isn't. Recall volume partly
// reflects product-line size and regulatory scrutiny, not just severity.
const RECALL_PENALTY_CAP: Record<string, number> = {
  "Class I": 45,
  "Class II": 30,
  "Class III": 12,
};

// FDA's own per-inspection classification (see migration 005). Same
// capped-per-class pattern as recalls, for the same reason: a facility with
// a long inspection history shouldn't be driven straight to 0 just because
// it's been inspected many times.
const INSPECTION_PENALTY: Record<string, number> = {
  OAI: 12,
  VAI: 5,
  NAI: 0,
};
const INSPECTION_PENALTY_CAP: Record<string, number> = {
  OAI: 40,
  VAI: 15,
  NAI: 0,
};

// regulatory_actions (migration 004) is agency-agnostic by design — the one
// example so far is Herbalife's FTC consent order. Flat per-action penalty,
// not doubled for active status like recalls: an "active" consent order
// often just means an ongoing compliance framework is still in effect, not
// necessarily a live escalating risk the way an unresolved recall is.
// Revisit this once there's a wider range of agencies/action types to judge
// severity by.
const REGULATORY_ACTION_PENALTY = 15;
const REGULATORY_ACTION_PENALTY_CAP = 40;

export function scoreRegulatoryCompliance(input: RegulatoryComplianceInput): number {
  const penaltyBySeverity: Record<string, number> = {};
  for (const recall of input.recalls) {
    const key = recall.classification ?? "unclassified";
    const unitPenalty = RECALL_PENALTY[key] ?? 5;
    const penalty = recall.status === "active" ? unitPenalty * 2 : unitPenalty;
    penaltyBySeverity[key] = (penaltyBySeverity[key] ?? 0) + penalty;
  }

  let recallPenalty = 0;
  for (const [key, penalty] of Object.entries(penaltyBySeverity)) {
    const cap = RECALL_PENALTY_CAP[key] ?? 20;
    recallPenalty += Math.min(penalty, cap);
  }

  // Rolls up across every facility linked to the current attribution,
  // matching manufacturer_attribution_facilities' own design intent: sum
  // company-level regulatory signal across all known candidate plants
  // rather than requiring one pinned facility. Not recency-weighted in
  // v1 — an old, resolved OAI counts the same as a recent one.
  const inspectionPenaltyByClass: Record<string, number> = {};
  for (const insp of input.inspectionClassifications) {
    const unitPenalty = INSPECTION_PENALTY[insp.classification] ?? 0;
    inspectionPenaltyByClass[insp.classification] =
      (inspectionPenaltyByClass[insp.classification] ?? 0) + unitPenalty;
  }
  let inspectionPenalty = 0;
  for (const [key, penalty] of Object.entries(inspectionPenaltyByClass)) {
    const cap = INSPECTION_PENALTY_CAP[key] ?? 20;
    inspectionPenalty += Math.min(penalty, cap);
  }

  const regulatoryActionPenalty = Math.min(
    input.regulatoryActions.length * REGULATORY_ACTION_PENALTY,
    REGULATORY_ACTION_PENALTY_CAP,
  );

  const totalPenalty = recallPenalty + inspectionPenalty + regulatoryActionPenalty;
  return Math.max(0, 100 - totalPenalty);
}

const ADVERSE_EVENT_BUCKETS: Array<[maxCount: number, value: number]> = [
  [0, 100],
  [50, 90],
  [200, 75],
  [500, 60],
];

export function scoreAdverseEvents(input: AdverseEventsInput): number | null {
  if (input.reportCount === null) return null;

  // Rough bucketing, not a rate — there's no sales-volume denominator here,
  // so a raw report count can't distinguish "1 report per 10 units sold"
  // from "1 report per 10 million." Per the product doc this subscore must
  // never be a primary driver regardless of how it's computed.
  for (const [maxCount, value] of ADVERSE_EVENT_BUCKETS) {
    if (input.reportCount <= maxCount) return value;
  }
  return 45;
}

export function scoreIngredientTransparency(
  input: IngredientTransparencyInput,
): number | null {
  const list = input.ingredientList;
  if (!list) return null;

  const hasBlend = (list.proprietaryBlends?.length ?? 0) > 0;
  const disclosedCount = (list.activeIngredients ?? []).filter(
    (i) => i.amountPerServing != null,
  ).length;

  if (hasBlend && disclosedCount === 0) return 25; // fully opaque proprietary blend
  if (hasBlend) return 55; // mixed: some doses disclosed, some blended
  if (disclosedCount > 0) return 95; // fully disclosed per-ingredient doses
  return null; // ingredient_list present but no recognizable structure
}

const TESTING_TIER_SCORE: Record<string, number> = {
  no_testing_claimed: 20,
  claimed_no_public_coa: 40,
  coa_not_per_lot: 65,
  public_per_lot_lookup: 100,
};

export function scoreTestingQuality(input: TestingQualityInput): number | null {
  if (!input.tier) return null;
  return TESTING_TIER_SCORE[input.tier] ?? null;
}

export function scoreCertifications(input: CertificationsInput): number | null {
  if (!input.certifications || input.certifications.length === 0) return null;
  const activeCount = input.certifications.filter((c) => c.status === "active").length;
  if (activeCount === 0) return 40; // certifications researched but none currently active
  return Math.min(100, 60 + activeCount * 20);
}
