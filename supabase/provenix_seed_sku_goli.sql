-- ============================================================================
-- PROVENIX — Seed SKU: Goli Apple Cider Vinegar Gummies (Sugar Free)
--
-- Batch-3 candidate #5 (viral DTC brand, new attribution pattern: two named
-- candidate manufacturers surfaced via litigation reporting, not a label
-- statement or FDA registration).
--
-- Attribution sources:
--   1. Label (photo reviewed directly, 2026-07-24): "Distributed by: Goli
--      Nutrition Inc. West Hollywood, CA 90069, United States of America" —
--      confirms the legal entity and a real address, but distributor only,
--      no manufacturer named.
--   2. SupplySide SJ (supplysidesj.com, published 2023-01-25, retrieved
--      2026-07-24): reports a federal lawsuit (U.S. District Court, Central
--      District of California) in which contract manufacturer Better
--      Nutritionals (Norco, CA, 420,000 sq ft facility) alleges Goli induced
--      it to expand capacity on inflated sales projections, then shifted
--      production to competitor Merical after taking a $100M investment from
--      VMG Partners, leaving Better Nutritionals with unsold inventory.
--      Better Nutritionals is seeking $200M+ in damages.
--
-- IMPORTANT: these are allegations in an active civil suit brought by an
-- interested party (the plaintiff manufacturer, as part of its own damages
-- claim), not a government enforcement finding or adjudicated fact — treated
-- as real but provisional evidence, held at source_type = 'inferred' rather
-- than 'enforcement_record'. Both candidate facilities are linked with
-- neither marked is_primary: Better Nutritionals as the past (per the suit)
-- manufacturer, Merical as the alleged current one — genuine temporal +
-- factual ambiguity, not just multiple plausible plants at one company (the
-- Pharmavite/P&G pattern). FDA Data Dashboard (inspections_classifications,
-- LegalName variants "Goli", "Goli Nutrition", "Goli Nutrition Inc", "Goli
-- Inc", retrieved 2026-07-24) returns no genuine match for Goli itself —
-- "Goli" alone surfaced 40 unrelated hits (Inner Mongolia pharmaceutical
-- companies, Margolin-surname entities), confirming fuzzy/substring
-- matching, not a real result.
--
-- Also notable: Goli Nutrition underwent a CCAA (Companies' Creditors
-- Arrangement Act) insolvency restructuring in Canada, sold in 2024 to a
-- consortium (Group KPS, Bastion Capital) per BeautyMatter (2024-03-25,
-- retrieved 2026-07-24) — context for why the manufacturer relationship was
-- unstable, not itself an attribution fact.
--
-- Kosher (OU) certification appears on-label but is skipped here, same
-- treatment as B Corp (Vital Proteins/OLLY) and QAI organic (Charlotte's
-- Web): a real third-party mark, but not a supplement-quality/safety cert
-- in the sense certification_type is meant to track.
-- ============================================================================

with brand_goli as (
    insert into brands (name, address, website)
    values (
        'Goli Nutrition',
        'Distributed by: Goli Nutrition Inc., West Hollywood, CA 90069, United States of America',
        'hellogoli.com'
    )
    returning id
),
product_goli as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        id,
        'Goli Apple Cider Vinegar Gummies, Sugar Free, 60 ct (UPC 055840405492)',
        'supplement_gmp',
        '{
            "servingSize": "2 gummies",
            "servingsPerContainer": 30,
            "activeIngredients": [
                {"name": "Vitamin B12 (Cyanocobalamin)", "amountPerServing": "2.4mcg", "percentDV": "100%"},
                {"name": "Apple Cider Vinegar (5% Acetic Acid)", "amountPerServing": "1000mg", "percentDV": null},
                {"name": "SNZ Tribac (R) Probiotic Blend (Bacillus coagulans SNZ 1969, Bacillus clausii SNZ 1971, Bacillus subtilis SNZ 1972; licensed from Sanzyme Biologics Private Limited)", "amountPerServing": "8mg", "percentDV": null}
            ],
            "otherIngredients": [
                "Soluble Tapioca Fiber", "Fructooligosaccharides", "Water", "Pectin", "Natural Flavors",
                "Citric Acid", "Sodium Citrate", "Fruit and Vegetable Juice (Color)", "Stevia Extract",
                "Beet Root Powder", "Pomegranate Powder"
            ]
        }'::jsonb,
        true
    from brand_goli
    returning id
),
facility_better_nutritionals as (
    insert into facilities (name, address, country, fei_number)
    values ('Better Nutritionals', 'Norco, CA (420,000 sq ft facility)', 'US', null)
    returning id
),
facility_merical as (
    insert into facilities (name, address, country, fei_number)
    values ('Merical', null, null, null)
    returning id
),
attribution_goli as (
    insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
    select
        id,
        'moderate'::attribution_confidence,
        'inferred'::attribution_source,
        'Label (photo reviewed directly, 2026-07-24): "Distributed by: Goli Nutrition Inc. West '
        || 'Hollywood, CA 90069, United States of America" — distributor only, no manufacturer named. '
        || 'SupplySide SJ (supplysidesj.com, published 2023-01-25, retrieved 2026-07-24): federal '
        || 'lawsuit, U.S. District Court, Central District of California — contract manufacturer '
        || 'Better Nutritionals (Norco, CA, 420,000 sq ft facility) alleges Goli induced it to expand '
        || 'capacity based on inflated sales projections, then shifted production to competitor '
        || 'Merical after a $100M VMG Partners investment, leaving Better Nutritionals with unsold '
        || 'inventory; seeking $200M+ in damages. FDA Data Dashboard (inspections_classifications, '
        || 'LegalName variants of "Goli", retrieved 2026-07-24) returns no genuine match — "Goli" '
        || 'alone surfaced 40 unrelated entities (Inner Mongolia pharmaceutical companies, '
        || 'Margolin-surname entities), confirming fuzzy/substring matching rather than a real result.',
        'Both Better Nutritionals and Merical linked as candidates, neither is_primary: these are '
        || 'allegations in an active civil suit brought by an interested party (the plaintiff '
        || 'manufacturer, as part of its own damages claim), not a government enforcement finding or '
        || 'adjudicated fact, and the two facilities represent different time periods (Better '
        || 'Nutritionals past, Merical alleged current) rather than simply several plausible plants '
        || 'at one company — genuinely more uncertain than the Pharmavite/P&G pattern, so confidence '
        || 'held at moderate and source_type at inferred rather than enforcement_record.'
    from product_goli
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select attribution_goli.id, f.id, false
from attribution_goli,
     (select id from facility_better_nutritionals union all select id from facility_merical) f;

-- ----------------------------------------------------------------------------
-- Lab testing: Tier 2, generic claim only
-- ----------------------------------------------------------------------------
insert into lab_testing (product_id, tier, evidence, source, last_verified)
select
    id,
    'claimed_no_public_coa'::lab_testing_tier,
    'goli.com (per Aaron, retrieved 2026-07-24): "You can rest assured knowing our products are '
    || 'tested at every stage of the process..." and "We test at every stage of our process, from '
    || 'manufacturing the gummy to quality checks upon packaging." A real but generic claim — no '
    || 'named third-party lab, no analyte list, no public per-lot CoA lookup found.',
    'web_research',
    now()
from products
where name = 'Goli Apple Cider Vinegar Gummies, Sugar Free, 60 ct (UPC 055840405492)';

-- No certifications insert: OU Kosher Pareve mark appears on-label but is not a
-- supplement-quality/safety certification (same treatment as B Corp and QAI organic
-- on other seed SKUs).
