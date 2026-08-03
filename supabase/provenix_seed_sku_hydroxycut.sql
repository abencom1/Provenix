-- ============================================================================
-- PROVENIX — Seed SKU: Hydroxycut Weight Loss Hardcore Rapid-Release
-- Capsules, 60 ct
--
-- 30-SKU push, candidate #8 and final SKU (30/30) — the deliberate
-- "expect problems" Tier C case, per the original worksheet's design
-- intent: weight-loss/stimulant products are FDA's heaviest supplement
-- enforcement category, and this brand has the most serious documented
-- history of any product in this dataset. Legal entity: Iovate Health
-- Sciences USA Inc. (distributor, Wilmington, DE), part of Iovate Health
-- Sciences International (Oakville, ON, Canada) — corporate structure
-- reported as a subsidiary of Xiwang per one source (LeadIQ, not
-- independently corroborated further, not load-bearing for this seed).
--
-- Attribution: label (photographed directly by Aaron, retrieved
-- 2026-08-03) reads "Distributed by Iovate Health Sciences U.S.A. Inc.
-- 1105 North Market Street, Suite 1330, Wilmington, DE 19801." FDA Data
-- Dashboard (inspections_classifications, LegalName="Iovate", retrieved
-- 2026-08-03) resolves to exactly one facility — FEI 3007318863, "Iovate
-- Health Sciences USA Inc.", Blasdell, NY. 5 unique inspections
-- (2009-01-14 NAI, 2009-05-01 VAI, 2012-05-23 NAI, 2017-09-11 NAI,
-- 2019-02-20 NAI) — the 2009-05-01 VAI lands exactly on the date of the
-- historic recall below, plausibly tied to the same investigation.
--
-- RECALLS (brand-level):
--   1. 2009-05-01, no FDA classification found: the well-documented
--      original Hydroxycut recall (CNN, CBS News, multiple law-firm
--      summaries, retrieved 2026-08-03) — FDA received 23 reports of
--      serious health problems (jaundice, elevated liver enzymes, liver
--      damage requiring transplant, one death, plus seizures,
--      cardiovascular disorders, rhabdomyolysis); Iovate voluntarily
--      recalled 14 Hydroxycut products, ~9 million packages sold the
--      prior year. Not in openFDA (pre-2013-ish coverage gap, same
--      pattern as Nature's Way/Garden of Life/NOW Foods 2011-2002
--      events) — no specific FDA classification found in any source
--      checked. This predates and is a different formulation from the
--      seeded Weight Loss Hardcore SKU, but is real, serious, and
--      directly shaped the brand''s current formulations and warnings.
--   2. 2024-12-18, Class II (openFDA food/enforcement.json, retrieved
--      2026-08-03, F-0455-2025): "Alpha Test" (a MuscleTech-branded
--      product, different brand under the same Iovate corporate umbrella
--      — NOT added here, since MuscleTech is its own brand, not a
--      Hydroxycut SKU or the same brand entity) — noted here only as
--      research context, not entered as a Hydroxycut brand recall.
--      Reason: presence of cathine, a controlled stimulant substance.
--
-- REGULATORY ACTIONS (brand-level, government actions only — private
-- class-action settlements deliberately excluded per this project''s
-- established Align/Cellucor precedent):
--   1. FTC settlement, 2010-07-14, $5.5 million (FDA Law Blog, retrieved
--      2026-08-03): false weight-loss/cold/flu/allergy advertising
--      claims across multiple Iovate products, including ads using
--      actors dressed as doctors and unsubstantiated "clinically proven"
--      claims. Source describes "5 of the company''s products" without
--      naming them individually in the text checked — recorded at brand
--      level rather than asserting Hydroxycut-specific product names not
--      directly confirmed.
--   2. 10-California-District-Attorneys settlement, 2012-01-16, $1.5
--      million ($1.2M civil penalties + $300K investigative costs)
--      (nutraingredients-usa.com, retrieved 2026-08-03): deceptive
--      advertising and California Prop 65 violations. No admission of
--      fault; injunctive terms on future advertising practices.
--
-- Adverse events (openFDA CAERS, retrieved 2026-08-03): 1,073 SUSPECT-
-- role reports under "Hydroxycut" — the largest count of any product in
-- this dataset. Spot-checked (5 of 5 sampled): all genuine Hydroxycut-
-- branded products (Hydroxycut, Hydroxycut Hardcore, Hydroxycut Hardcore
-- X, Hydroxycut SX7), correct industry category, not name-collision noise
-- (unlike "Vega" or "AG1", "Hydroxycut" is not a generic string).
--
-- Ingredient list: THREE named proprietary blends, but with genuinely
-- mixed internal disclosure, not uniform opacity:
--   - "Yohimbacore Robusta Blend" (250mg) is actually FULLY accounted for
--     at the component level (green coffee extract 200mg + yohimbe
--     extract 50mg = 250mg exactly) — modeled as two individually-dosed
--     activeIngredients, not an opaque blend, since nothing is actually
--     hidden despite the "Blend" branding.
--   - "Pyroxyclene Anhydranine Blend" (368mg) discloses caffeine''s
--     specific contribution (265mg) but not L-theanine''s or cayenne
--     pepper''s — genuinely partial opacity, modeled as a real
--     proprietaryBlends entry.
--   - "1,3 D-Norepidrol Blend" (128mg) discloses zero individual amounts
--     for its 4 components (all common amino acids/compounds, not the
--     banned stimulant DMAA despite the deliberately similar-sounding
--     name) — modeled as a real proprietaryBlends entry.
--
-- Yohimbe safety context (NIH/NCCIH, ConsumerLab, retrieved 2026-08-03,
-- not entered as a DB row — no schema field for ingredient-level safety
-- literature short of an FDA action): yohimbe/yohimbine is associated in
-- the literature with cardiac arrhythmia, hypertension, seizures, and at
-- high doses, death; accounted for an outsized share of poison-control
-- supplement cases in cited research. Real, relevant context for why this
-- ingredient specifically draws scrutiny, though not itself a confirmed
-- FDA regulatory action beyond what's already captured above.
--
-- No ndi_flags row: green coffee extract as a weight-loss ingredient has
-- drawn real regulatory/FTC scrutiny industry-wide (a different, well-
-- known case than this specific brand), but wasn't independently chased
-- to an NDI-notification conclusion here given the scope already covered.
-- ============================================================================

with brand_hydroxycut as (
    insert into brands (name, address, website)
    values (
        'Hydroxycut',
        'Iovate Health Sciences U.S.A. Inc., 1105 North Market Street, Suite 1330, Wilmington, DE '
        || '19801, USA (distributor; parent Iovate Health Sciences International, Oakville, ON, Canada)',
        'www.hydroxycut.com'
    )
    returning id
),
product_hydroxycut as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        id,
        'Hydroxycut Weight Loss Hardcore Rapid-Release Capsules, 60 ct',
        'supplement_gmp',
        '{
            "servingSize": "2 Capsules",
            "servingsPerContainer": 30,
            "activeIngredients": [
                {"name": "Green coffee extract (as C. canephora robusta) (seed), standardized for 45% chlorogenic acids", "amountPerServing": "200 mg", "percentDV": null},
                {"name": "Yohimbe extract (as Pausinystalia yohimbe) (bark), standardized for 6% yohimbine", "amountPerServing": "50 mg", "percentDV": null}
            ],
            "proprietaryBlends": [
                {
                    "name": "Pyroxyclene Anhydranine Blend",
                    "components": ["Caffeine anhydrous (supplying 265 mg of caffeine)", "L-theanine", "Cayenne pepper (as Capsicum annuum) (fruit)"],
                    "note": "368 mg total; caffeine's specific 265mg contribution is disclosed, but L-theanine and cayenne pepper amounts are not"
                },
                {
                    "name": "1,3 D-Norepidrol Blend",
                    "components": ["L-tyrosine", "L-methionine", "L-leucine", "Trans-ferulic acid"],
                    "note": "128 mg total, no individual component amounts disclosed"
                }
            ],
            "otherIngredients": ["Capsule (Gelatin, Titanium Dioxide, FD&C Red No. 40, FD&C Blue No. 1)", "Microcrystalline Cellulose", "Magnesium Stearate", "Silicon Dioxide"]
        }'::jsonb,
        true
    from brand_hydroxycut
    returning id
),
facility_blasdell as (
    insert into facilities (name, address, country, fei_number)
    values (
        'Iovate Health Sciences USA Inc. — Blasdell facility',
        'Blasdell, NY, USA',
        'US',
        '3007318863'
    )
    returning id
),
attribution_hydroxycut as (
    insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
    select
        id,
        'high'::attribution_confidence,
        'user_photo'::attribution_source,
        'Label (photographed directly by Aaron, retrieved 2026-08-03): "Distributed by Iovate Health '
        || 'Sciences U.S.A. Inc. 1105 North Market Street, Suite 1330, Wilmington, DE 19801." FDA Data '
        || 'Dashboard (inspections_classifications, LegalName="Iovate", retrieved 2026-08-03) resolves '
        || 'to exactly one facility -- FEI 3007318863, "Iovate Health Sciences USA Inc.", Blasdell, NY. '
        || '5 unique inspections (2009-2019): 4 NAI, 1 VAI (dated 2009-05-01, the same date as the '
        || 'historic recall below).',
        'Single unambiguous FDA-registered facility, distributor-typed label language notwithstanding '
        || '-- same reasoning pattern as New Chapter, Nature''s Way, and AG1.'
    from product_hydroxycut
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select attribution_hydroxycut.id, facility_blasdell.id, true
from attribution_hydroxycut, facility_blasdell;

-- ----------------------------------------------------------------------------
-- Inspection history (FDA Data Dashboard, FEI 3007318863, retrieved 2026-08-03)
-- ----------------------------------------------------------------------------
insert into inspection_classifications (facility_id, classification, inspection_end_date, source, retrieved_at)
select f.id, v.classification::inspection_classification, v.inspection_end_date::date,
       'fda_data_dashboard_inspections_classifications', now()
from facilities f,
     (values
        ('NAI', '2009-01-14'),
        ('VAI', '2009-05-01'),
        ('NAI', '2012-05-23'),
        ('NAI', '2017-09-11'),
        ('NAI', '2019-02-20')
     ) as v(classification, inspection_end_date)
where f.fei_number = '3007318863';

-- ----------------------------------------------------------------------------
-- Recall: 2009 historic Hydroxycut recall (trade press + FDA/CDC-adjacent
-- press coverage, retrieved 2026-08-03; not in openFDA)
-- ----------------------------------------------------------------------------
insert into recalls (brand_id, recall_date, classification, reason, status, source, openfda_ref)
select b.id, '2009-05-01'::date, null,
       'FDA received 23 reports of serious health problems associated with Hydroxycut products, '
       || 'ranging from jaundice and elevated liver enzymes to liver damage requiring a liver '
       || 'transplant, one death, plus seizures, cardiovascular disorders, and rhabdomyolysis. Iovate '
       || 'voluntarily recalled 14 Hydroxycut products (~9 million packages sold the prior year). '
       || 'Different formulation than the seeded Weight Loss Hardcore SKU, but real, serious brand '
       || 'history that directly shaped current formulations/warnings. No FDA classification found in '
       || 'any source checked; not in openFDA (pre-2013-ish coverage gap, verified 2026-08-03).',
       'closed'::record_status, 'trade_press_2009', null
from brands b where b.name = 'Hydroxycut';

-- ----------------------------------------------------------------------------
-- Regulatory actions (government actions only, retrieved 2026-08-03)
-- ----------------------------------------------------------------------------
insert into regulatory_actions (brand_id, agency, action_type, issued_date, status, summary, source, retrieved_at)
select b.id, 'FTC', 'settlement', '2010-07-14'::date, 'closed',
       '$5.5 million settlement over false weight-loss/cold/flu/allergy advertising claims across '
       || 'multiple Iovate products, including ads using actors dressed as doctors and '
       || 'unsubstantiated "clinically proven" claims. Source describes "5 of the company''s products" '
       || 'without naming them individually in the text checked -- recorded at brand level.',
       'fda_law_blog_2010', now()
from brands b where b.name = 'Hydroxycut'
union all
select b.id, 'California District Attorneys (10 counties, joint action)', 'settlement', '2012-01-16'::date, 'closed',
       '$1.5 million settlement ($1.2M civil penalties + $300K investigative costs) over deceptive '
       || 'advertising and California Proposition 65 violations. No admission of fault; injunctive '
       || 'terms on future advertising practices.',
       'nutraingredients_usa_2012', now()
from brands b where b.name = 'Hydroxycut';

-- ----------------------------------------------------------------------------
-- Adverse events (openFDA CAERS, retrieved 2026-08-03)
-- ----------------------------------------------------------------------------
insert into adverse_event_counts (brand_id, report_count, data_period, source)
select b.id, 1073, 'cumulative through 2026-08-03', 'openfda_hfcs'
from brands b where b.name = 'Hydroxycut';

-- ----------------------------------------------------------------------------
-- Lab testing (web research, retrieved 2026-08-03) — filled in for
-- completeness after the same "sparse data inflates the score" pattern
-- found with Herbalife: overall_score was 75 on 4 of 6 subscores before
-- this and the certifications check, vs. 69 on 5 of 6 after.
-- ----------------------------------------------------------------------------
with p as (select id from products where name = 'Hydroxycut Weight Loss Hardcore Rapid-Release Capsules, 60 ct')
insert into lab_testing (product_id, tier, evidence, source, last_verified)
select p.id, 'claimed_no_public_coa'::lab_testing_tier,
       'Iovate claims third-party ingredient/formula safety review and per-batch testing, per its '
       || 'own site (iovate.com). No public per-lot CoA lookup tool found. No third-party '
       || 'certification marks (NSF, USP, Informed-Choice) visible on the physical label.',
       'web_research', now()
from p;
