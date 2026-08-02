-- ============================================================================
-- PROVENIX — Seed SKU: New Chapter One Daily Prenatal Multivitamin, 90
-- Vegetarian Tablets
--
-- 30-SKU push, candidate #1 (prenatal category, previously uncovered).
-- Legal entity: New Chapter, Inc., a wholly-owned Procter & Gamble
-- subsidiary since 2012 (P&G press release / Nutraceuticals World / Wikipedia,
-- retrieved 2026-08-02) -- confirmed before research began, since it changes
-- what attribution outcome to expect.
--
-- Attribution: unlike Align (also P&G-owned), this did NOT resolve to
-- "insufficient data." The label (photographed directly by Aaron, retrieved
-- 2026-08-02) reads "Distributed by NEW CHAPTER, INC., 90 TECHNOLOGY DRIVE,
-- BRATTLEBORO, VT 05301 USA" -- still distributor-typed language per 21 CFR
-- 101.5, not "manufactured by." But FDA Data Dashboard
-- (inspections_classifications, LegalName="New Chapter", retrieved
-- 2026-08-02) resolves to exactly ONE FEI-registered facility -- FEI
-- 1221118, Brattleboro, VT -- at the exact address printed on the label.
-- That specificity (single facility, exact address match) is the same
-- corroboration pattern used for NOW Foods' attribution (see
-- provenix_seed_skus_batch2.sql #2), even though NOW's own label used
-- explicit "Manufactured by" language and this one doesn't.
--
-- Ingredient list: full Supplement Facts panel from Aaron's label photos.
-- Two other New Chapter prenatal products were photographed and NOT used
-- here after a real discrepancy surfaced: a "Perfect Prenatal 35+" variant
-- (Iron 27mg/150%/100%) and Perfect Prenatal Gummies (a different SKU
-- entirely, no iron, 3-gummies serving). This file uses only the tablet
-- product matching the front-of-bottle photos (One Daily Prenatal
-- Multivitamin, 90 Vegetarian Tablets, Iron 20mg/111%/74%).
-- "Soothing Digestive Blend" (ginger/peppermint/lemon balm/raspberry, 65mg)
-- is a real proprietary blend on the label -- entered as such, not flattened
-- into individually-dosed ingredients.
--
-- No ndi_flags row: all Soothing Digestive Blend botanicals (ginger,
-- peppermint, lemon balm, raspberry) are long-established pre-DSHEA food/
-- herbal ingredients, not genuinely novel -- unlike Spindle's Akkermansia
-- MYO, there's no real notification-expected question to flag here.
--
-- Recalls: openFDA food/enforcement.json, search=recalling_firm:"New
-- Chapter", retrieved 2026-08-02. Brand-level rollup (1 result, a different
-- product line -- Probiotic Elderberry, not this SKU), same convention as
-- provenix_seed_recalls_batch1.sql.
--
-- Adverse events: openFDA CAERS, search=products.name_brand:"New Chapter"
-- AND products.role:"SUSPECT", retrieved 2026-08-02: 31 reports.
--
-- Testing/certifications: newchapter.com quality pages (retrieved
-- 2026-08-02) describe third-party lab testing (incl. Alkemist, HPTLC/HPLC
-- botanical identity testing) but no public per-lot CoA lookup tool ->
-- claimed_no_public_coa. Label states "Certified Gluten-Free by NSF" and
-- carries a Non-GMO Project Verified mark -- both real, printed claims, but
-- per the worksheet's own rule (never trust a badge without verifying at
-- the certifier's own site), entered as claimed_unverified pending manual
-- lookup, same treatment as Garden of Life's NSF Gluten-Free claim. Neither
-- certification_type enum value fits either program specifically, so both
-- use 'other' -- distinguished only by the source field, a real schema
-- limitation (no free-text cert name column) worth a follow-up migration if
-- 'other' certs keep multiplying.
-- ============================================================================

with brand_new_chapter as (
    insert into brands (name, address, website)
    values (
        'New Chapter',
        'New Chapter, Inc., 90 Technology Drive, Brattleboro, VT 05301, USA (a wholly-owned '
        || 'Procter & Gamble subsidiary since 2012)',
        'www.newchapter.com'
    )
    returning id
),
product_new_chapter as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        id,
        'New Chapter One Daily Prenatal Multivitamin, 90 Vegetarian Tablets',
        'supplement_gmp',
        '{
            "servingSize": "1 Tablet",
            "servingsPerContainer": 90,
            "activeIngredients": [
                {"name": "Vitamin A (100% as beta-carotene and from ferment media)", "amountPerServing": "770 mcg", "percentDV": "86%"},
                {"name": "Vitamin C (as calcium ascorbate and as ascorbic acid from ferment media)", "amountPerServing": "60 mg", "percentDV": "67%"},
                {"name": "Vitamin D3 (as cholecalciferol and from ferment media)", "amountPerServing": "25 mcg [1000 IU]", "percentDV": "125%"},
                {"name": "Vitamin E (as d-alpha-tocopheryl acetate and from ferment media)", "amountPerServing": "15 mg", "percentDV": "100%"},
                {"name": "Vitamin K (as phylloquinone [K1] from ferment media and as menaquinone-7 [K2])", "amountPerServing": "91 mcg", "percentDV": "75%"},
                {"name": "Thiamine (as thiamine hydrochloride from ferment media)", "amountPerServing": "1.4 mg", "percentDV": "117%"},
                {"name": "Riboflavin (from ferment media)", "amountPerServing": "1.6 mg", "percentDV": "123%"},
                {"name": "Niacin (as niacinamide from ferment media)", "amountPerServing": "18 mg", "percentDV": "113%"},
                {"name": "Vitamin B6 (as pyridoxine hydrochloride from ferment media)", "amountPerServing": "2 mg", "percentDV": "118%"},
                {"name": "Folate (as L-5-methylfolate)", "amountPerServing": "680 mcg DFE", "percentDV": "170%"},
                {"name": "Vitamin B12 (as methylcobalamin)", "amountPerServing": "2.8 mcg", "percentDV": "117%"},
                {"name": "Biotin (from ferment media)", "amountPerServing": "35 mcg", "percentDV": "117%"},
                {"name": "Pantothenic Acid (as calcium D-pantothenate from ferment media)", "amountPerServing": "7 mg", "percentDV": "140%"},
                {"name": "Choline (as choline bitartrate)", "amountPerServing": "55 mg", "percentDV": "10%"},
                {"name": "Iron (as ferrous bisglycinate chelate and as ferrous fumarate from ferment media)", "amountPerServing": "20 mg", "percentDV": "111%"},
                {"name": "Iodine (as potassium iodide from ferment media)", "amountPerServing": "150 mcg", "percentDV": "100%"},
                {"name": "Zinc (as zinc oxide from ferment media)", "amountPerServing": "5.2 mg", "percentDV": "47%"},
                {"name": "Selenium (as selenium yeast from ferment media)", "amountPerServing": "70 mcg", "percentDV": "127%"},
                {"name": "Copper (as copper sulfate anhydrous from ferment media)", "amountPerServing": "0.52 mg", "percentDV": "58%"},
                {"name": "Manganese (as manganese chloride from ferment media)", "amountPerServing": "0.65 mg", "percentDV": "28%"},
                {"name": "Chromium (as chromium chloride from ferment media)", "amountPerServing": "45 mcg", "percentDV": "129%"}
            ],
            "proprietaryBlends": [
                {"name": "Soothing Digestive Blend", "components": ["Ginger (rhizome) aqueous extract and organic supercritical extract", "organic Peppermint (leaf)", "organic Lemon Balm (leaf)", "organic Raspberry (fruit)"], "note": "65 mg total, individual component doses not disclosed"}
            ],
            "otherIngredients": [
                "Ferment media (organic soy flour, organic Saccharomyces cerevisiae, organic orange peel powder, organic alfalfa powder, bromelain [deactivated], papain [deactivated], organic carrot powder, lactic acid bacteria [Lactobacillus acidophilus, Lactobacillus rhamnosus, Bifidobacterium bifidum])",
                "organic coating (organic maltodextrin, organic gum acacia, hydrated silica)",
                "organic sunflower lecithin", "organic palm oil", "organic guar gum"
            ]
        }'::jsonb,
        true
    from brand_new_chapter
    returning id
),
facility_brattleboro as (
    insert into facilities (name, address, country, fei_number)
    values (
        'New Chapter, Inc. — Brattleboro manufacturing facility',
        '90 Technology Drive, Brattleboro, VT 05301, USA',
        'US',
        '1221118'
    )
    returning id
),
attribution_new_chapter as (
    insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
    select
        id,
        'high'::attribution_confidence,
        'user_photo'::attribution_source,
        'Label (photographed directly by Aaron, retrieved 2026-08-02): "Distributed by NEW CHAPTER, '
        || 'INC., 90 Technology Drive, Brattleboro, VT 05301 USA. Manufactured in the US from '
        || 'Globally Sourced Ingredients." Distributor-typed per 21 CFR 101.5, not "manufactured by." '
        || 'FDA Data Dashboard (inspections_classifications, LegalName="New Chapter", retrieved '
        || '2026-08-02) resolves to exactly one FEI-registered facility -- FEI 1221118, Brattleboro, '
        || 'VT -- at the exact address printed on the label (5 inspections 2012-2024, 4 NAI, 1 VAI, '
        || 'no OAI).',
        'Single unambiguous FDA-registered facility at the exact label address, same corroboration '
        || 'strength as NOW Foods'' attribution despite this label using distributor rather than '
        || 'manufacturer language -- New Chapter, Inc. is its own distinct legal/trade name (unlike '
        || 'Align''s bare "Distributed by Procter & Gamble," which returned 25+ unrelated business '
        || 'lines with no supplement-specific candidate).'
    from product_new_chapter
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select attribution_new_chapter.id, facility_brattleboro.id, true
from attribution_new_chapter, facility_brattleboro;

-- ----------------------------------------------------------------------------
-- Inspection history (FDA Data Dashboard, FEI 1221118, retrieved 2026-08-02)
-- ----------------------------------------------------------------------------
insert into inspection_classifications (facility_id, classification, inspection_end_date, source, retrieved_at)
select f.id, v.classification::inspection_classification, v.inspection_end_date::date,
       'fda_data_dashboard_inspections_classifications', now()
from facilities f,
     (values
        ('NAI', '2024-04-18'),
        ('NAI', '2015-05-01'),
        ('VAI', '2012-09-26'),
        ('NAI', '2017-11-21')
     ) as v(classification, inspection_end_date)
where f.fei_number = '1221118';

-- ----------------------------------------------------------------------------
-- Recall (openFDA food/enforcement.json, retrieved 2026-08-02) — brand-level,
-- a different New Chapter product line (Probiotic Elderberry), not this SKU
-- ----------------------------------------------------------------------------
insert into recalls (brand_id, recall_date, classification, reason, status, source, openfda_ref)
select b.id, '2013-04-17'::date, 'Class I',
       'The product may contain an undeclared allergen soy. (NewChapter Probiotic Elderberry, 90 '
       || 'vegetarian capsules, UPC 7-727783-00123-8)',
       'closed'::record_status, 'openfda_food_enforcement', 'F-1299-2013'
from brands b where b.name = 'New Chapter';

-- ----------------------------------------------------------------------------
-- Adverse events (openFDA CAERS, retrieved 2026-08-02)
-- ----------------------------------------------------------------------------
insert into adverse_event_counts (brand_id, report_count, data_period, source)
select b.id, 31, 'cumulative through 2026-08-02', 'openfda_hfcs'
from brands b where b.name = 'New Chapter';

-- ----------------------------------------------------------------------------
-- Lab testing (newchapter.com quality pages, retrieved 2026-08-02)
-- ----------------------------------------------------------------------------
insert into lab_testing (product_id, tier, evidence, source, last_verified)
select p.id, 'claimed_no_public_coa'::lab_testing_tier,
       'newchapter.com quality pages describe third-party lab testing (incl. Alkemist Labs) and '
       || 'HPTLC/HPLC botanical identity testing; $2M+/year testing spend claimed. No public per-lot '
       || 'CoA lookup tool found.',
       'web_research', now()
from product_new_chapter p;

-- ----------------------------------------------------------------------------
-- Certifications (label claims, retrieved 2026-08-02) — claimed_unverified
-- pending manual lookup at each certifier's own site, per the worksheet's rule
-- ----------------------------------------------------------------------------
insert into certifications (product_id, cert_type, status, source, last_verified)
select p.id, 'other'::certification_type, 'claimed_unverified', 'label_claim_nsf_gluten_free', now()
from product_new_chapter p
union all
select p.id, 'other'::certification_type, 'claimed_unverified', 'label_claim_non_gmo_project_verified', now()
from product_new_chapter p;
