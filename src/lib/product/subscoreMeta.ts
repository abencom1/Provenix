import type { SubscoreType } from '@/lib/scoring/types';

export const SUBSCORE_LABELS: Record<SubscoreType, string> = {
  manufacturer_transparency: 'Manufacturer Transparency',
  regulatory_compliance: 'Regulatory & Compliance History',
  testing_quality: 'Testing & Quality Transparency',
  third_party_certifications: 'Third-Party Certifications',
  ingredient_transparency: 'Ingredient Transparency',
  adverse_events: 'Adverse Events',
};

// Display-only bucketing threshold for the "helping / hurting" grouping —
// not a scoring rule, just a UI grouping heuristic (score_model_v1 itself
// has no notion of helping/hurting).
export const HELPING_THRESHOLD = 70;
