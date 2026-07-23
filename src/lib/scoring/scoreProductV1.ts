import {
  scoreAdverseEvents,
  scoreCertifications,
  scoreIngredientTransparency,
  scoreManufacturerTransparency,
  scoreRegulatoryCompliance,
  scoreTestingQuality,
} from "./subscores";
import type {
  ProductScoringInput,
  SubscoreResult,
  SubscoreType,
  TrustScoreResultV1,
} from "./types";

// Weights are intentionally not stored in the DB (see provenix_schema.sql's
// own comment on this) so the "minimum viable score" decision doesn't block
// ingestion. adverse_events is deliberately weighted lowest — it must never
// read as a primary driver of the score.
const WEIGHTS: Record<SubscoreType, number> = {
  manufacturer_transparency: 0.3,
  regulatory_compliance: 0.25,
  testing_quality: 0.15,
  third_party_certifications: 0.15,
  ingredient_transparency: 0.1,
  adverse_events: 0.05,
};

export function scoreProductV1(input: ProductScoringInput): TrustScoreResultV1 {
  const subscores: SubscoreResult[] = [
    {
      type: "manufacturer_transparency",
      value: scoreManufacturerTransparency(input.manufacturerTransparency),
    },
    {
      type: "regulatory_compliance",
      value: scoreRegulatoryCompliance(input.regulatoryCompliance),
    },
    { type: "testing_quality", value: scoreTestingQuality(input.testingQuality) },
    {
      type: "third_party_certifications",
      value: scoreCertifications(input.certifications),
    },
    {
      type: "ingredient_transparency",
      value: scoreIngredientTransparency(input.ingredientTransparency),
    },
    { type: "adverse_events", value: scoreAdverseEvents(input.adverseEvents) },
  ];

  const present = subscores.filter((s) => s.value !== null);

  // Minimum-viable-score rule (agreed with Aaron 2026-07-23): manufacturer
  // attribution must be present, plus at least one other subscore, or the
  // product isn't scorable at all. Manufacturer resolution is the point of
  // the product, so a product with neither that nor anything else can't score.
  const manufacturerPresent =
    subscores.find((s) => s.type === "manufacturer_transparency")?.value !== null;
  const isScorable = manufacturerPresent && present.length >= 2;

  if (!isScorable) {
    return {
      productId: input.productId,
      overallScore: null,
      isScorable: false,
      explanation:
        `Insufficient data to score: ${present.length} of 6 subscores available` +
        (manufacturerPresent ? "" : "; manufacturer attribution unresolved"),
      subscores,
    };
  }

  const totalWeight = present.reduce((sum, s) => sum + WEIGHTS[s.type], 0);
  const overallScore = Math.round(
    present.reduce((sum, s) => sum + (s.value as number) * WEIGHTS[s.type], 0) /
      totalWeight,
  );

  return {
    productId: input.productId,
    overallScore,
    isScorable: true,
    explanation: `Scored from ${present.length} of 6 available subscores (weights renormalized).`,
    subscores,
  };
}
