-- ============================================================================
-- PROVENIX — Seed SKU: OLLY Sleep Melatonin Gummies (Blackberry & Mint)
--
-- Batch-3 candidate #3 (melatonin/gummy category, new to the seed set).
-- Manufacturer unresolved — same archetype as Align (real, known distributor,
-- manufacturer undisclosed), reinforced here by an affirmative company
-- statement rather than just inferring from label phrasing:
--   - Label (photo reviewed directly, 2026-07-24): "Distributed by OLLY
--     Public Benefit Corp., San Francisco, CA 94111" — no manufacturer or
--     facility named anywhere on the panel reviewed.
--   - OLLY's own site, 2019 language (per Aaron, retrieved 2026-07-24):
--     "We partner with various domestic and international manufacturing
--     facilities to create our gummies... For our gummy supplement line,
--     all are made in the USA with the exception of [products] made in
--     Colombia—as indicated on the product label."
--   - OLLY's current site language (per Aaron, retrieved 2026-07-24): "OLLY
--     vitamins and supplements are made in facilities located in the United
--     States and other countries. Products manufactured outside of the US
--     are labeled as such."
-- Both company statements confirm contract manufacturing across multiple,
-- unnamed facilities (not vertically integrated) — stronger than a bare
-- "distributed by" line, but still no specific facility to link. FDA Data
-- Dashboard (inspections_classifications, LegalName variants: "OLLY", "OLLY
-- PBC", "OLLY Public Benefit Corp[oration]", "OLLY Nutrition", "Olly Inc",
-- "Olly LLC", retrieved 2026-07-24) returns zero genuine matches — "OLLY"
-- alone surfaced 80 unrelated hits (Holly/Molly/Polly/Jolly-named entities),
-- confirming the filter does fuzzy/substring matching, not exact, so this
-- was a real negative, not a filter artifact.
--
-- Not yet confirmed whether this specific SKU is US- or Colombia-made — not
-- visible on the label panel reviewed. Doesn't change the attribution
-- outcome either way (still no named facility), but worth resolving later
-- if a front-panel photo turns up.
-- ============================================================================

with brand_olly as (
    insert into brands (name, address, website)
    values (
        'OLLY',
        'Distributed by OLLY Public Benefit Corp., San Francisco, CA 94111',
        'www.olly.com'
    )
    returning id
),
product_olly as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        id,
        'OLLY Sleep Melatonin Gummies, Blackberry & Mint (UPC 858158005121)',
        'supplement_gmp',
        '{
            "servingSize": "2 gummies",
            "activeIngredients": [
                {"name": "Melatonin", "amountPerServing": null, "percentDV": null}
            ],
            "otherIngredients": []
        }'::jsonb,
        true
    from brand_olly
    returning id
)
insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
select
    id,
    null,
    null,
    'Label (photo reviewed directly, 2026-07-24): "Distributed by OLLY Public Benefit Corp., San '
    || 'Francisco, CA 94111" — no manufacturer/facility named. OLLY site language, 2019 version (per '
    || 'Aaron): "We partner with various domestic and international manufacturing facilities to '
    || 'create our gummies... made in the USA with the exception of [products] made in Colombia." '
    || 'Current OLLY site language (per Aaron): "OLLY vitamins and supplements are made in facilities '
    || 'located in the United States and other countries. Products manufactured outside of the US are '
    || 'labeled as such." FDA Data Dashboard (inspections_classifications, LegalName variants of '
    || '"OLLY", retrieved 2026-07-24) returns zero genuine matches — the plain "OLLY" query returned '
    || '80 unrelated Holly/Molly/Polly/Jolly-named entities, confirming fuzzy/substring matching '
    || 'rather than a filter miss.',
    'Two affirmative company statements (2019 and current) confirm contract manufacturing across '
    || 'multiple unnamed domestic and international facilities — stronger evidence of NON-vertical-'
    || 'integration than Align''s bare "distributed by" line, but still no single named facility to '
    || 'link. Genuine "insufficient data," left with zero rows in manufacturer_attribution_facilities.'
from product_olly;

insert into lab_testing (product_id, tier, evidence, source, last_verified)
select
    id,
    'claimed_no_public_coa'::lab_testing_tier,
    'OLLY site (per Aaron, retrieved 2026-07-24): "(All) OLLY products are tested by accredited '
    || 'third party labs to confirm quality and safety before they ever reach your hands... Our '
    || 'quality assurance and monitoring programs include rigorous testing, which incorporates heavy '
    || 'metal and micro testing. All product testing is done at a third party, accredited, industry '
    || 'recognized laboratory. Test results must meet established specification limits in accordance '
    || 'with regulatory requirements and safety standards." A real, specific testing claim (heavy '
    || 'metal + micro testing, third-party lab, spec-limit pass/fail), but no public per-lot CoA '
    || 'lookup tool or posted CoA found or mentioned anywhere. The separate "Contents Certified NSF" '
    || 'mark on-label is logged in certifications, not counted toward this tier.',
    'web_research',
    now()
from products
where name = 'OLLY Sleep Melatonin Gummies, Blackberry & Mint (UPC 858158005121)';

-- ----------------------------------------------------------------------------
-- Certification: "Contents Certified NSF" mark on-label. Logged as
-- claimed_unverified pending manual verification at NSF's own site (per the
-- established rule: never trust a badge image alone). Flagging explicitly:
-- NSF's "Contents Certified" program verifies label-claim accuracy — it is
-- NOT the same as full NSF/ANSI 173 product certification, so cert_type is
-- logged as 'other' rather than 'nsf_ansi_173' to avoid overstating it.
-- ----------------------------------------------------------------------------
insert into certifications (product_id, cert_type, status, source, last_verified)
select
    id,
    'other'::certification_type,
    'claimed_unverified',
    'label_review: NSF "Contents Certified" mark on this product''s label (a label-claim-accuracy '
    || 'program, distinct from full NSF/ANSI 173 certification). OLLY''s site (per Aaron, retrieved '
    || '2026-07-24) separately describes a broader NSF relationship — "independent product testing, '
    || 'facility audits, and routine surveillance of products and manufacturing activities" — which '
    || 'reads as more rigorous than a plain Contents Certified mark, but this is the brand''s own '
    || 'general marketing description, not verified against which specific NSF program this product '
    || 'is actually enrolled in. Do not upgrade cert_type from the on-label mark until checked '
    || 'directly at nsf.org.',
    now()
from products
where name = 'OLLY Sleep Melatonin Gummies, Blackberry & Mint (UPC 858158005121)';
