-- ============================================================================
-- PROVENIX — Backfill: Thorne (Captomer) and Optimum Nutrition (Lyons
-- Magnus RTD) recalls, surfaced by a retailer/press re-check of the 22
-- already-seeded brands
--
-- First 2 of 3 distinct methodology gaps found in this pass, all beyond
-- the pre-2004/press-only gap already found for Nature's Way:
--
-- Gap #2 (this file, Thorne): the recall exists in openFDA, but under
-- drug/enforcement.json, not food/enforcement.json -- every prior search
-- in this project (including the original "Thorne and FGO: zero recalls
-- found" conclusion in provenix_seed_recalls_batch1.sql) only ever queried
-- the food endpoint. Captomer/Captomer-250 were marketed as dietary
-- supplements but contained DMSA, a prescription drug's active ingredient,
-- making them unapproved new drugs -- which is presumably why FDA filed
-- the recall as a drug action. recalling_firm:"Thorne" AND drug/
-- enforcement.json, retrieved 2026-08-02: 2 results, both Class II,
-- terminated, recall_initiation_date 2014-06-12, termination_date
-- 2014-10-15. Different product line than the seeded Ashwagandha/Vitamin D
-- SKUs -- brand-level rollup per convention.
--
-- Gap #3 (this file, Optimum Nutrition): the recall exists in openFDA
-- food/enforcement.json, but under recalling_firm:"Lyons Magnus, Inc" (the
-- actual co-packer/manufacturer), not "Optimum Nutrition" -- every search
-- in this project so far has queried recalling_firm by brand name only.
-- For contract-manufactured brands (most of this project's Tier B/C
-- products), this means recalls filed under the manufacturer's own name
-- are systematically invisible to a brand-name-only search. Verified via
-- recalling_firm:"Lyons Magnus" AND product_description:"Gold Standard",
-- retrieved 2026-08-02: 2 results, F-1662-2022 and F-1661-2022, both
-- Class I, "Findings and potential for Cronobacter sakazakii and
-- Clostridium botulinum," recall_initiation_date 2022-07-22, termination
-- 2024-07-25. Product: Gold Standard 100% Whey Chocolate/Vanilla, 11 fl oz
-- ready-to-drink cartons -- a different product form (RTD liquid) than the
-- seeded powder tub, made at a different facility (Lyons Magnus, Fresno CA
-- -- a co-packer, not necessarily the same plant that fills the seeded
-- product) -- brand-level rollup per convention, not linked to the seeded
-- SKU's specific facility.
-- ============================================================================

insert into recalls (brand_id, recall_date, classification, reason, status, source, openfda_ref)
select b.id, '2014-06-12'::date, 'Class II',
       'Marketed Without An Approved NDA/ANDA: Captomer and Captomer-250 (heavy-metal chelation '
       || 'products) were marketed as dietary supplements but list DMSA (meso-2,3-dimercaptosuccinic '
       || 'acid) as sourced from an ingredient that is the active ingredient in an FDA-approved '
       || 'prescription drug, making these unapproved new drugs. Filed under openFDA drug/'
       || 'enforcement.json, not food/enforcement.json -- a different endpoint than the one '
       || 'originally checked for this brand.',
       'closed'::record_status, 'openfda_drug_enforcement', 'D-1384-2014 / D-1383-2014'
from brands b where b.name = 'Thorne'
union all
select b.id, '2022-07-22'::date, 'Class I',
       'Findings and potential for Cronobacter sakazakii and Clostridium botulinum. Gold Standard '
       || '100% Whey Chocolate and Vanilla, 11 fl oz ready-to-drink cartons (a different product '
       || 'form than the seeded powder tub), recalled by co-packer Lyons Magnus, Inc (Fresno, CA) -- '
       || 'part of a wider 90-product Lyons Magnus recall spanning multiple brands (Premier Protein, '
       || 'Oatly, Kate Farms, and others). Filed under recalling_firm:"Lyons Magnus," not "Optimum '
       || 'Nutrition" -- invisible to a brand-name-only openFDA search.',
       'closed'::record_status, 'openfda_food_enforcement', 'F-1662-2022 / F-1661-2022'
from brands b where b.name = 'Optimum Nutrition';
