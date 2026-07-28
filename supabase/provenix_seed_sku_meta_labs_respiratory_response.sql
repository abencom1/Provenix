-- ============================================================================
-- PROVENIX — Seed SKU: Meta Labs Respiratory Response
--
-- Batch-4 candidate #2, picked to exercise `warning_letters`, which had zero
-- rows across all 20+1 prior seed SKUs despite the table/RLS existing since
-- the original schema. Primary source: full text of FDA Warning Letter
-- CMS #725130 (issued 2026-05-15 to Meta Labs Pharmaceuticals, LLC),
-- retrieved directly by Aaron from fda.gov and pasted in full into this
-- session — not paraphrased from search snippets or press coverage (both of
-- which were tried first and 404'd/couldn't be fetched automatically).
--
-- A genuinely different attribution pattern from every prior SKU: Meta Labs
-- is both the brand AND the manufacturer, at a single named, addressed
-- facility — the warning letter is itself the inspection record proving the
-- link (FDA inspected "your facility located at 1009 Mansell Rd Ste J,
-- Roswell, GA 30076" and reviewed labels/website for products Meta Labs
-- sells under its own name). No FEI number is disclosed in the letter body
-- itself, so facilities.fei_number is left null rather than guessed.
--
-- The letter covers six Meta Labs products total (Diabetic Advantage, Yacon
-- Root Extract, Nattokinase Max, Viral Immune Booster, Arthritis Bursitis
-- Rheumatism, Respiratory Response), all found to be unapproved new drugs /
-- misbranded on the same disease-claim theory. Respiratory Response is
-- seeded as the representative SKU here because it is also one of only two
-- products (with Diabetic Advantage) additionally cited for CGMP violations
-- that make it "adulterated" under 402(g)(1) — i.e. it hits all three
-- violation categories in the letter, not just the drug-claim one. The
-- other five products are not separately seeded as SKUs; this file's
-- warning_letters.summary lists all six so the full scope isn't lost.
-- ============================================================================

with brand_metalabs as (
    insert into brands (name, address, website)
    values (
        'Meta Labs Pharmaceuticals',
        '1009 Mansell Rd Ste J, Roswell, GA 30076, United States. Private-label dietary supplement '
        || 'manufacturer that also sells finished products under its own name (Meta Labs is both '
        || 'brand and manufacturer for this SKU, per the facility address named in FDA Warning Letter '
        || 'CMS #725130).',
        'www.metalabsinc.com'
    )
    returning id
),
product_respresponse as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        id,
        'Meta Labs Respiratory Response, 590 mg, 120 capsules',
        'supplement_gmp',
        '{
            "servingSize": null,
            "activeIngredients": [
                {"name": "Tylophora", "amountPerServing": null, "percentDV": null},
                {"name": "Bupleurum", "amountPerServing": null, "percentDV": null},
                {"name": "Long Pepper", "amountPerServing": null, "percentDV": null},
                {"name": "Ginger", "amountPerServing": null, "percentDV": null}
            ],
            "otherIngredients": [],
            "note": "Ingredient names and 590 mg total per the product name/label as quoted in FDA Warning Letter CMS #725130 (2026-05-15). Per-ingredient amounts and serving size were not disclosed in the letter and have not been independently verified against the product label itself."
        }'::jsonb,
        true
    from brand_metalabs
    returning id
),
facility_metalabs as (
    insert into facilities (name, address, country)
    values (
        'Meta Labs Pharmaceuticals, LLC',
        '1009 Mansell Rd Ste J, Roswell, GA 30076',
        'US'
    )
    returning id
),
attribution_respresponse as (
    insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
    select
        id,
        'high'::attribution_confidence,
        'enforcement_record'::attribution_source,
        'FDA Warning Letter CMS #725130 (issued 2026-05-15, addressed to Bassam T. Khayat, Owner, '
        || 'Meta Labs Pharmaceuticals, LLC): FDA "conducted an inspection of your facility located at '
        || '1009 Mansell Rd Ste J, Roswell, GA 30076 from December 8 through December 18, 2025," and '
        || 'reviewed product labels collected during that inspection plus www.metalabsinc.com — the '
        || 'same site through which Meta Labs sells Respiratory Response. Full letter text retrieved '
        || 'directly from fda.gov by Aaron, 2026-07-28.',
        'is_primary = true: unlike every prior SKU''s attribution (a third-party brand pointing to a '
        || 'separate contract manufacturer), this is a direct FDA inspection record of the brand''s own '
        || 'named facility selling product under its own name — about as strong as attribution evidence '
        || 'gets, even though it arrives via an enforcement action rather than a clean label statement.'
    from product_respresponse
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select attribution_respresponse.id, facility_metalabs.id, true
from attribution_respresponse, facility_metalabs;

-- ----------------------------------------------------------------------------
-- Warning letter: full text retrieved and pasted by Aaron, 2026-07-28.
-- Status 'active' — letter is current as of its own "Content current as of:
-- 06/02/2026" footer, no close-out letter found or referenced.
-- ----------------------------------------------------------------------------
insert into warning_letters (facility_id, brand_id, issued_date, status, url, summary, source, retrieved_at)
select
    f.id,
    b.id,
    '2026-05-15'::date,
    'active'::record_status,
    'https://www.fda.gov/inspections-compliance-enforcement-and-criminal-investigations/warning-letters/meta-labs-pharmaceuticals-llc-725130-05152026',
    'FDA Warning Letter CMS #725130 to Meta Labs Pharmaceuticals, LLC (Roswell, GA), following a '
    || 'Dec 8-18, 2025 inspection. Cites six products -- Diabetic Advantage, Yacon Root Extract, '
    || 'Nattokinase Max, Viral Immune Booster, Arthritis Bursitis Rheumatism, and Respiratory Response '
    || '-- as unapproved new drugs (21 U.S.C. 321(g)(1)(B)) based on disease cure/mitigation/treatment '
    || '/prevention claims on labels and metalabsinc.com (e.g. Respiratory Response marketed to '
    || '"fight...shortness of breath and congestion from asthma, exercise induced asthma, emphysema, '
    || 'allergies, bronchitis, colds, and flu"; product name "Arthritis Bursitis Rheumatism" itself '
    || 'treated as a claim). Same five products (all but Arthritis Bursitis Rheumatism) additionally '
    || 'cited as misbranded drugs (21 U.S.C. 352(f)(1), lack adequate directions for lay use). '
    || 'Diabetic Advantage and Respiratory Response specifically are further cited as adulterated '
    || 'dietary supplements (21 U.S.C. 342(g)(1)) for CGMP violations under 21 CFR Part 111: missing '
    || 'finished-product and component specifications, incomplete master manufacturing records and '
    || 'batch production records, and inadequate lab-control reference-standard procedures. No FDA '
    || 'response/close-out on file as of retrieval.',
    'fda_warning_letters',
    now()
from facilities f, brands b
where f.name = 'Meta Labs Pharmaceuticals, LLC'
  and b.name = 'Meta Labs Pharmaceuticals';

-- No lab_testing/certifications insert: the warning letter's CGMP findings (missing finished-product
-- specs, no component identity testing) are a compliance violation, not a testing-tier claim -- they
-- belong under regulatory_compliance conceptually, not testing_quality.
--
-- Update, 2026-07-28: src/lib/scoring/subscores.ts and scripts/runScoring.ts were extended (same
-- session) to read warning_letters into regulatory_compliance -- flat 20-point penalty per letter
-- (40 if status='active'), capped at 50 total. This row (status='active') should apply the full
-- 40-point penalty once npm run score is rerun after this file is loaded.
