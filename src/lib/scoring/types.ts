export type AttributionConfidence = "high" | "moderate" | "low" | null;

export type ManufacturerTransparencyInput = {
  confidence: AttributionConfidence;
  facilityCount: number;
};

export type RecallRecord = {
  classification: string | null;
  status: "active" | "closed";
};

export type InspectionClassificationRecord = {
  classification: "NAI" | "VAI" | "OAI";
};

export type RegulatoryActionRecord = {
  status: "active" | "closed";
};

export type WarningLetterRecord = {
  status: "active" | "closed";
};

// A Tier-I regulator's action against an INGREDIENT (excipient_regulatory_actions,
// via the product_excipient_regulatory_flags view) — distinct from
// RegulatoryActionRecord above, which is a brand/facility-level action (FTC,
// state AGs, etc.). Every row reaching this type is already scoreable by
// construction (the view has no regulator filter) — see
// provenix_excipient_personalization_spec_v0.5.md §10.5/§10.6.
export type ExcipientRegulatoryActionRecord = {
  status: "active" | "closed";
};

export type NdiFlagRecord = {
  expectedNotification: boolean;
  notificationFound: boolean;
};

export type RegulatoryComplianceInput = {
  recalls: RecallRecord[];
  inspectionClassifications: InspectionClassificationRecord[];
  regulatoryActions: RegulatoryActionRecord[];
  warningLetters: WarningLetterRecord[];
  ndiFlags: NdiFlagRecord[];
  excipientRegulatoryActions: ExcipientRegulatoryActionRecord[];
};

export type AdverseEventsInput = {
  reportCount: number | null;
};

export type IngredientRow = {
  name: string;
  amountPerServing?: string | null;
};

export type ProprietaryBlend = {
  name: string;
  components: string[];
};

export type IngredientListShape = {
  activeIngredients?: IngredientRow[];
  proprietaryBlends?: ProprietaryBlend[];
};

export type IngredientTransparencyInput = {
  ingredientList: IngredientListShape | null;
};

export type LabTestingTier =
  | "no_testing_claimed"
  | "claimed_no_public_coa"
  | "coa_not_per_lot"
  | "public_per_lot_lookup"
  | null;

export type TestingQualityInput = {
  tier: LabTestingTier;
};

export type CertificationRecord = {
  status: string | null;
};

export type CertificationsInput = {
  certifications: CertificationRecord[] | null;
};

export type SubscoreType =
  | "manufacturer_transparency"
  | "regulatory_compliance"
  | "testing_quality"
  | "third_party_certifications"
  | "ingredient_transparency"
  | "adverse_events";

export type SubscoreResult = {
  type: SubscoreType;
  value: number | null;
};

export type ProductScoringInput = {
  productId: string;
  manufacturerTransparency: ManufacturerTransparencyInput;
  regulatoryCompliance: RegulatoryComplianceInput;
  adverseEvents: AdverseEventsInput;
  ingredientTransparency: IngredientTransparencyInput;
  testingQuality: TestingQualityInput;
  certifications: CertificationsInput;
};

export type TrustScoreResultV1 = {
  productId: string;
  overallScore: number | null;
  isScorable: boolean;
  explanation: string;
  subscores: SubscoreResult[];
};
