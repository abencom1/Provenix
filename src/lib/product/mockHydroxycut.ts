import { scoreProductV1 } from '@/lib/scoring/scoreProductV1';
import type { ProductScoringInput } from '@/lib/scoring/types';

import type { ProductDetail } from './types';

// Mirrors supabase/provenix_seed_sku_hydroxycut.sql (retrieved 2026-08-03).
// Stands in for a live Supabase fetch until the client ships an anon key —
// same shape a real query result would produce, run through the same
// versioned scoring function, so swapping in real data later is a data-layer
// change only, not a UI change.
//
// The manufacturer/trust-score/facility-record/contested-excipient data
// below is REAL (drawn straight from the seed file, including its real
// disclosed capsule-shell ingredients: gelatin, titanium dioxide, magnesium
// stearate, silicon dioxide). The ingredient regulatory flag, its
// multi-source note, the certification icons, and the compatibility flag
// are ILLUSTRATIVE — no product in the live database has real excipient
// regulatory/certification/compatibility rows seeded yet (verified via
// scripts/testExcipientLayerBoundaries.ts's own zero-row checks). They
// reuse the v0.5 spec's own canonical examples rather than inventing new
// claims. excipientRegulatoryActions is deliberately left OUT of the actual
// scoring input below, so the displayed Trust Score stays the real,
// unmodified Hydroxycut number — the illustrative flag never quietly
// contaminates a real score.
const scoringInput: ProductScoringInput = {
  productId: 'hydroxycut-weight-loss-hardcore-60ct',
  manufacturerTransparency: { confidence: 'high', facilityCount: 1 },
  regulatoryCompliance: {
    recalls: [{ classification: null, status: 'closed' }],
    inspectionClassifications: [
      { classification: 'NAI' },
      { classification: 'VAI' },
      { classification: 'NAI' },
      { classification: 'NAI' },
      { classification: 'NAI' },
    ],
    regulatoryActions: [{ status: 'closed' }, { status: 'closed' }],
    warningLetters: [],
    ndiFlags: [],
    excipientRegulatoryActions: [],
  },
  adverseEvents: { reportCount: 1073 },
  ingredientTransparency: {
    ingredientList: {
      activeIngredients: [
        { name: 'Green coffee extract', amountPerServing: '200 mg' },
        { name: 'Yohimbe extract', amountPerServing: '50 mg' },
      ],
      proprietaryBlends: [
        { name: 'Pyroxyclene Anhydranine Blend', components: ['Caffeine anhydrous', 'L-theanine', 'Cayenne pepper'] },
        { name: '1,3 D-Norepidrol Blend', components: ['L-tyrosine', 'L-methionine', 'L-leucine', 'Trans-ferulic acid'] },
      ],
    },
  },
  testingQuality: { tier: 'claimed_no_public_coa' },
  certifications: { certifications: null },
};

const VERIFIED = '2026-08-03';

export const mockHydroxycut: ProductDetail = {
  id: scoringInput.productId,
  name: 'Hydroxycut Weight Loss Hardcore Rapid-Release Capsules, 60 ct',
  brandName: 'Hydroxycut',
  attribution: {
    confidence: 'high',
    sourceDetail: 'Label (photographed by Aaron) + FDA Data Dashboard inspection records',
    verifiedAt: VERIFIED,
    facilities: [
      {
        id: 'facility-blasdell',
        name: 'Iovate Health Sciences USA Inc.',
        address: 'Blasdell, NY, USA · FEI 3007318863',
        isPrimary: true,
      },
    ],
  },
  trustScore: scoreProductV1(scoringInput),
  subscoreDetails: [
    {
      type: 'manufacturer_transparency',
      value: 100,
      headline:
        'High confidence — one FDA-registered facility, confirmed from the product label and FDA Data Dashboard.',
      verifiedAt: VERIFIED,
    },
    {
      type: 'regulatory_compliance',
      value: 60,
      headline:
        '5 FDA inspections (4 clean, 1 voluntary-action finding), 1 closed recall, and 2 closed government settlements on the facility/brand record.',
      verifiedAt: VERIFIED,
    },
    {
      type: 'testing_quality',
      value: 40,
      headline:
        'Brand claims third-party testing but publishes no public per-lot Certificate of Analysis lookup.',
      verifiedAt: VERIFIED,
    },
    {
      // scoreCertifications returns null (not 40) when no certifications
      // row exists at all — the 40 "researched, none active" branch only
      // fires when a row exists but isn't active. Hydroxycut has no row,
      // so this subscore drops out of the weighted average entirely rather
      // than scoring as a researched negative. Confirmed against the live
      // trust_subscores row (2026-08-06): third_party_certifications is
      // null there too, and the real overall score (69, "5 of 6 available
      // subscores") only matches once this one is excluded.
      type: 'third_party_certifications',
      value: null,
      headline: 'No certification data on file yet — not researched, not the same as researched-and-failed.',
      verifiedAt: null,
    },
    {
      type: 'ingredient_transparency',
      value: 55,
      headline:
        '2 named proprietary blends disclose some but not all component amounts; 2 other active ingredients are fully dosed.',
      verifiedAt: VERIFIED,
    },
    {
      type: 'adverse_events',
      value: 45,
      headline:
        '1,073 reports on file in FDA’s adverse event system — the highest count in this dataset.',
      verifiedAt: VERIFIED,
    },
  ],
  facilityRecords: [
    { label: 'Inspection · 2019-02-20', detail: 'No Action Indicated (NAI)', status: 'closed' },
    { label: 'Inspection · 2017-09-11', detail: 'No Action Indicated (NAI)', status: 'closed' },
    { label: 'Inspection · 2012-05-23', detail: 'No Action Indicated (NAI)', status: 'closed' },
    { label: 'Inspection · 2009-05-01', detail: 'Voluntary Action Indicated (VAI)', status: 'closed' },
    { label: 'Inspection · 2009-01-14', detail: 'No Action Indicated (NAI)', status: 'closed' },
    {
      label: 'Recall · 2009-05-01',
      detail:
        '14 Hydroxycut products voluntarily recalled after 23 reports of serious health problems. Different formulation than this SKU. No FDA classification on record.',
      status: 'closed',
    },
    {
      label: 'FTC settlement · 2010-07-14',
      detail: '$5.5M settlement over false advertising claims across multiple Iovate products.',
      status: 'closed',
    },
    {
      label: '10 CA District Attorneys settlement · 2012-01-16',
      detail: '$1.5M settlement over deceptive advertising and Prop 65 violations.',
      status: 'closed',
    },
  ],
  // ILLUSTRATIVE below this line. Titanium dioxide is a real disclosed
  // capsule-shell ingredient per the seed file's otherIngredients array —
  // the regulatory action / multi-source note content is the v0.5 spec's
  // own canonical example, not researched for this specific SKU.
  ingredientRegulatoryFlags: [
    {
      excipientName: 'Titanium dioxide',
      regulator: 'EFSA',
      detail: "Removed from the EU's permitted food-additives list, cited genotoxicity concerns.",
      jurisdiction: 'EU',
      effectiveDate: '2022-05-14',
      status: 'active',
      otherSources: [
        { source: 'FDA', statement: 'No action taken as of this record’s last verification.' },
        {
          source: 'IARC (WHO)',
          statement: 'Classified as [group] in [year]. Informational only, never scored.',
        },
      ],
    },
  ],
  certifications: [
    { category: 'vegan', label: 'Vegan', present: true, certifyingBody: 'Vegan Action (illustrative)' },
    { category: 'non_gmo', label: 'Non-GMO', present: true, certifyingBody: 'Non-GMO Project (illustrative)' },
    { category: 'kosher', label: 'Kosher', present: false, certifyingBody: null },
    { category: 'halal', label: 'Halal', present: false, certifyingBody: null },
    { category: 'gluten_free', label: 'Gluten-Free', present: false, certifyingBody: null },
  ],
  compatibilityFlags: [
    { practice: 'halal', message: 'Contains gelatin (porcine) — conflicts with your halal preference.' },
  ],
  // Real: both are in the seed file's otherIngredients array.
  contestedExcipients: ['Magnesium stearate', 'Silicon dioxide'],
  adverseEventCount: 1073,
  testingTier: 'claimed_no_public_coa',
  correctionLog: [],
  excipientDataIsIllustrative: true,
};
