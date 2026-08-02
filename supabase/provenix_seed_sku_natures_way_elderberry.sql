-- ============================================================================
-- PROVENIX — Seed SKU: Nature's Way Sambucus Elderberry Immune Gummy, Zero
-- Sugar, 70 Gummies (35 servings x 2 gummies)
--
-- 30-SKU push, candidate #2 (elderberry/immune category, previously
-- uncovered). Legal entity: Nature's Way Brands, LLC, Green Bay, WI --
-- a subsidiary of Schwabe Group (Germany-based plant-pharmaceutical
-- company) since 2003 (Nutraceuticals World, retrieved 2026-08-02).
--
-- Label discrepancy, not used here: two front-label photos were taken, one
-- reading "70 GUMMIES" and one "60 GUMMIES," otherwise identical design --
-- almost certainly two different retail pack sizes of the same product line.
-- The full Supplement Facts panel photographed states "Servings Per
-- Container 35" at a 2-gummy serving size (= 70 gummies), so this file
-- seeds the 70-count product specifically, matching the verified panel.
--
-- Attribution: FDA Data Dashboard (inspections_classifications, retrieved
-- 2026-08-02) for LegalName="Nature's Way" returns 3 distinct companies --
-- a real name-collision case, same pattern as the NBTY/Glanbia sister-brand
-- exclusions in provenix_seed_recalls_adverse_events_batch2.sql:
--   - "Nature's Way Farms, LLC" (Pharr, TX) -- an unrelated produce/fresh-
--     fruit importer, NOT this brand. Has a real 2022 OAI, but excluded --
--     applying it here would misattribute one company's problem to another.
--   - "NATURES WAY PURE WATER SYSTEMS INC" (Pittston, PA) -- an unrelated
--     water-filtration company. Excluded.
--   - "NATURE'S WAY" (Green Bay, WI, FEI 3012631639) -- matches the label's
--     printed address exactly. This is the real facility: 2 inspections,
--     both NAI (2022-06-28, 2024-01-26), no OAI/VAI.
--
-- Recalls (openFDA food/enforcement.json, search=recalling_firm:"Nature's
-- Way", retrieved 2026-08-02): the only hit is "Nature's Way Purewater
-- Systems, Inc." (the same unrelated water company, ESSENTIA bottled water
-- mold recall) -- excluded for the same name-collision reason. Zero recalls
-- attributable to the actual supplement brand; no row inserted.
--
-- Adverse events (openFDA CAERS, search=products.name_brand:"Nature's Way"
-- AND products.role:"SUSPECT", retrieved 2026-08-02): 100 reports. Spot-
-- checked 10 of the 10 sampled results before trusting the count -- all
-- classified under industry code 54 ("Vit/Min/Prot/Unconv Diet"), confirming
-- these are genuine supplement reports, not the produce/water companies
-- bleeding into the same brand-name search.
--
-- Testing: naturesway.com's "Know What's In Your Bottle" tool (retrieved
-- 2026-08-02) is a real public tool showing identity/purity/potency/
-- composition/contaminant testing per product -- but searchable by product
-- name/SKU, not by the lot number printed on a specific bottle. Same
-- coa_not_per_lot tier as Ritual (real tool, not lot-verifiable), not the
-- majority claimed_no_public_coa default.
--
-- Certifications: no certification entered for this specific SKU. The
-- brand holds NSF/ANSI 455-2 GMP facility certification and other brand-
-- wide certs (Non-GMO Project, USDA Organic elsewhere in the line), but
-- none of those were confirmed as applying to this exact product from the
-- label photos -- the round "V" seal visible is ambiguous (could be a
-- vegan mark, not a certified-gluten-free mark) and there's no "Certified
-- ___ by ___" text on this label the way New Chapter's explicitly named
-- NSF. NSF/ANSI 455-2 itself is facility GMP, not a product-quality
-- certification our schema tracks (same reasoning as excluding Herbalife's
-- ISO 45001).
--
-- No ndi_flags row: Black Elder (Sambucus nigra) is a long-established
-- pre-DSHEA botanical, not a genuinely novel ingredient.
-- ============================================================================

with brand_natures_way as (
    insert into brands (name, address, website)
    values (
        'Nature''s Way',
        'Nature''s Way Brands, LLC, Green Bay, WI 54311, USA (a subsidiary of Schwabe Group, '
        || 'Germany, since 2003)',
        'www.naturesway.com'
    )
    returning id
),
product_elderberry as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        id,
        'Nature''s Way Sambucus Elderberry Immune Gummy, Zero Sugar, 70 Gummies',
        'supplement_gmp',
        '{
            "servingSize": "2 Gummies",
            "servingsPerContainer": 35,
            "activeIngredients": [
                {"name": "Vitamin C (ascorbic acid)", "amountPerServing": "90 mg", "percentDV": "100%"},
                {"name": "Vitamin D3 (as cholecalciferol)", "amountPerServing": "30 mcg (1,200 IU)", "percentDV": "150%"},
                {"name": "Zinc (as zinc citrate)", "amountPerServing": "7.5 mg", "percentDV": "68%"},
                {"name": "Sodium", "amountPerServing": "15 mg", "percentDV": "1%"},
                {"name": "Black Elder (Sambucus nigra L.) (berry) Extract, standardized to anthocyanins from 3,200 mg of premium cultivar elderberries", "amountPerServing": "50 mg", "percentDV": null}
            ],
            "otherIngredients": [
                "soluble corn fiber", "allulose", "pectin", "natural flavors", "sodium citrate",
                "citric acid", "monk fruit extract", "organic stevia (leaf) extract"
            ]
        }'::jsonb,
        true
    from brand_natures_way
    returning id
),
facility_green_bay as (
    insert into facilities (name, address, country, fei_number)
    values (
        'Nature''s Way Brands, LLC — Green Bay manufacturing facility',
        'Green Bay, WI 54311, USA',
        'US',
        '3012631639'
    )
    returning id
),
attribution_natures_way as (
    insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
    select
        id,
        'high'::attribution_confidence,
        'user_photo'::attribution_source,
        'Label (photographed directly by Aaron, retrieved 2026-08-02): "©2025 Nature''s Way Brands, '
        || 'LLC, Green Bay, WI 54311 USA. Bottled and tested in the USA." FDA Data Dashboard '
        || '(inspections_classifications, LegalName="Nature''s Way", retrieved 2026-08-02) returns 3 '
        || 'distinct companies under similar names -- Nature''s Way Farms LLC (Pharr, TX, an unrelated '
        || 'produce importer) and Natures Way Pure Water Systems Inc (Pittston, PA, unrelated water '
        || 'filtration), both excluded as sister-name collisions -- and "NATURE''S WAY" (Green Bay, WI, '
        || 'FEI 3012631639), which matches the label''s printed city/state exactly. 2 inspections, '
        || 'both NAI, no OAI/VAI.',
        'Exact city/state match to the label after ruling out two real but unrelated same-named '
        || 'companies -- same sister-brand-name-collision pattern already established for recalls/'
        || 'adverse-events exclusions (see provenix_seed_recalls_adverse_events_batch2.sql), applied '
        || 'here to facility attribution itself.'
    from product_elderberry
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select attribution_natures_way.id, facility_green_bay.id, true
from attribution_natures_way, facility_green_bay;

-- ----------------------------------------------------------------------------
-- Inspection history (FDA Data Dashboard, FEI 3012631639, retrieved 2026-08-02)
-- ----------------------------------------------------------------------------
insert into inspection_classifications (facility_id, classification, inspection_end_date, source, retrieved_at)
select f.id, v.classification::inspection_classification, v.inspection_end_date::date,
       'fda_data_dashboard_inspections_classifications', now()
from facilities f,
     (values
        ('NAI', '2022-06-28'),
        ('NAI', '2024-01-26')
     ) as v(classification, inspection_end_date)
where f.fei_number = '3012631639';

-- No recalls row: zero attributable after excluding the Pure Water Systems
-- name collision (see comment above) -- absence is itself the finding.

-- ----------------------------------------------------------------------------
-- Adverse events (openFDA CAERS, retrieved 2026-08-02)
-- ----------------------------------------------------------------------------
insert into adverse_event_counts (brand_id, report_count, data_period, source)
select b.id, 100, 'cumulative through 2026-08-02', 'openfda_hfcs'
from brands b where b.name = 'Nature''s Way';

-- ----------------------------------------------------------------------------
-- Lab testing (naturesway.com "Know What's In Your Bottle" tool, retrieved
-- 2026-08-02)
-- ----------------------------------------------------------------------------
insert into lab_testing (product_id, tier, evidence, source, last_verified)
select p.id, 'coa_not_per_lot'::lab_testing_tier,
       'naturesway.com "Know What''s In Your Bottle" tool: searchable by product name/SKU/ingredient, '
       || 'shows real identity/purity/potency/composition/contaminants testing results from their '
       || 'ISO 17025-accredited lab. Not searchable by the lot number printed on a specific bottle, '
       || 'so not a Tier 4 per-lot lookup.',
       'web_research', now()
from product_elderberry p;
