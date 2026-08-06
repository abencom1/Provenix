import type { LabTestingTier, SubscoreType, TrustScoreResultV1 } from '@/lib/scoring/types';

export type FacilityRef = {
  id: string;
  name: string;
  address: string | null;
  isPrimary: boolean;
};

export type ManufacturerAttributionDetail = {
  confidence: 'high' | 'moderate' | 'low' | null;
  sourceDetail: string | null;
  verifiedAt: string; // ISO date
  facilities: FacilityRef[];
};

export type RegulatoryRecordSummary = {
  label: string;
  detail: string;
  status: 'active' | 'closed' | null;
};

// A single Tier-I regulator's stance, or a non-Tier-I (WHO/IARC) note, on the
// same ingredient — rendered together at equal weight, never ranked. See
// provenix_excipient_personalization_spec_v0.5.md §9.1.1.
export type MultiSourceStatement = {
  source: string; // e.g. 'FDA', 'EFSA', 'IARC (WHO)'
  statement: string;
};

export type IngredientRegulatoryFlag = {
  excipientName: string;
  regulator: string;
  detail: string;
  jurisdiction: string | null;
  effectiveDate: string; // ISO date
  status: 'active' | 'closed';
  otherSources: MultiSourceStatement[];
};

export type CorrectionLogEntry = {
  whatChanged: string;
  reason: string;
  correctedAt: string; // ISO date
};

export type SubscoreDetail = {
  type: SubscoreType;
  value: number | null;
  headline: string;
  verifiedAt: string | null;
};

export type CertificationIcon = {
  category: 'kosher' | 'halal' | 'vegan' | 'non_gmo' | 'gluten_free';
  label: string;
  present: boolean;
  certifyingBody: string | null;
};

export type CompatibilityFlagDisplay = {
  practice: string;
  message: string;
};

export type ProductDetail = {
  id: string;
  name: string;
  brandName: string;
  attribution: ManufacturerAttributionDetail;
  trustScore: TrustScoreResultV1;
  subscoreDetails: SubscoreDetail[];
  facilityRecords: RegulatoryRecordSummary[];
  ingredientRegulatoryFlags: IngredientRegulatoryFlag[];
  certifications: CertificationIcon[];
  compatibilityFlags: CompatibilityFlagDisplay[];
  contestedExcipients: string[];
  adverseEventCount: number | null;
  testingTier: LabTestingTier;
  correctionLog: CorrectionLogEntry[];
  // The excipient-layer fields above (ingredientRegulatoryFlags, certifications,
  // compatibilityFlags, contestedExcipients) are illustrative placeholder data —
  // no product in the live database has real excipient rows seeded yet. See
  // mockHydroxycut.ts.
  excipientDataIsIllustrative: boolean;
};
