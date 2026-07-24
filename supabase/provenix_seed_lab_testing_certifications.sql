-- ============================================================================
-- PROVENIX — Lab testing tiers and certifications for all 13 seed products
-- (retrieved 2026-07-24). Full sourcing in provenix_seed_sku_findings.md.
--
-- Certifications: sourced from DSLD's own structured label statements (a
-- legitimate public NIH source), NOT from scraping NSF/USP/Informed-Choice's
-- own databases (their ToS forbids that, per provenix_data_sources.md).
-- Logged as status = 'claimed_unverified' — a human still needs to check
-- each certifier's own lookup tool before treating any of these as confirmed
-- active. See findings doc for exactly which 5 need that manual check.
--
-- Lab testing tiers: checked each brand's own public testing claims/tools
-- directly (no ToS restriction on this). Only Nordic Naturals confirmed a
-- genuine public per-lot CoA lookup (Tier 4) — a real result, not an
-- assumption that bigger/pricier brands automatically score higher.
-- ============================================================================

with p as (select id, name from products where is_seed_sku)
insert into lab_testing (product_id, tier, evidence, source, last_verified)
select p.id, v.tier::lab_testing_tier, v.evidence, v.source, now()
from p
join (values
    ('Nature Made Vitamin D3 2000 IU (50 mcg) Softgels — Item #2585', 'claimed_no_public_coa',
     'Extensive internal testing claimed (HPLC, IR, mass spectrophotometry) and supplier CoA requirements; no public per-lot lookup tool found.',
     'web_research'),
    ('Garden of Life Vitamin Code — Women (UPC 6 58010 11417 2)', 'claimed_no_public_coa',
     'Third-party batch/raw-material testing claimed; CoAs are publicly posted for their CBD product line specifically, not for this multivitamin.',
     'web_research'),
    ('Thorne Ashwagandha', 'claimed_no_public_coa',
     'Confirmed via thorne.com/quality: "4 rounds of testing," 2 in-house labs, but no consumer-facing lot-lookup tool.',
     'web_research'),
    ('FGO Organic Ashwagandha Root Powder (16oz)', 'no_testing_claimed',
     'No testing claim of any kind found — only organic/Non-GMO certifications, consistent with this brand''s overall opacity.',
     'web_research'),
    ('NOW Foods Magnesium Citrate (UPC 7 33739 01294 4)', 'claimed_no_public_coa',
     'Has a public CoA portal (cofa.nowfoods.com) but it is scoped to essential oils only; does not cover this product.',
     'web_research'),
    ('Thorne Vitamin D (liquid drops, UPC 6 93749 16801 0)', 'claimed_no_public_coa',
     'Same brand-wide testing profile as Thorne Ashwagandha: internal 4-round testing, no public lot-lookup tool.',
     'web_research'),
    ('Optimum Nutrition Gold Standard 100% Whey, Double Rich Chocolate (UPC 7 48927 05226 8)', 'claimed_no_public_coa',
     'Facility-level NSF/Informed-Choice/BRCGS certifications exist; no public per-lot CoA search tool found.',
     'web_research'),
    ('Nordic Naturals Ultimate Omega, Lemon', 'public_per_lot_lookup',
     'Confirmed real tool at nordic.com/nordic-promise: enter the lot number from the bottle, or scan its QR code, to view potency/purity/freshness/contaminant results.',
     'web_research'),
    ('Ritual Essential for Women, Mint Essenced', 'coa_not_per_lot',
     'Real "Certificate of Traceability" publishes per-formula heavy-metal/microbe testing info, but it is unconfirmed whether an individual bottle''s specific lot number is searchable -- not claiming Tier 4 without that confirmation.',
     'web_research'),
    ('Nature''s Bounty Fish Oil 1200 mg (UPC 0 74312 16887 1)', 'claimed_no_public_coa',
     'Explicitly confirmed: no broad public U.S. batch-level COA portal; shoppers cannot verify individual lots numerically.',
     'web_research'),
    ('Kirkland Signature Extra Strength Vitamin D3 2000 IU (UPC 0 96619 39391 6)', 'claimed_no_public_coa',
     'USP-verification claim is well supported brand-wide; no public per-lot CoA tool found.',
     'web_research'),
    ('Spring Valley Turmeric Curcumin 500 mg (UPC 6 81131 15679 0)', 'claimed_no_public_coa',
     'Supplier raw-material CoAs and finished-product third-party testing claimed; no public per-lot lookup tool found.',
     'web_research'),
    ('Cellucor C4 Original, Cherry (UPC 8 42595 13469 8)', 'claimed_no_public_coa',
     'General Nutrabolt testing claims exist, but the clearest citation found ties to a new India manufacturing announcement, not clearly this specific product line.',
     'web_research')
) as v(product_name, tier, evidence, source) on v.product_name = p.name;

with p as (select id, name from products where is_seed_sku)
insert into certifications (product_id, cert_type, status, source)
select p.id, v.cert_type::certification_type, 'claimed_unverified', 'dsld_label_claim'
from p
join (values
    ('Nature Made Vitamin D3 2000 IU (50 mcg) Softgels — Item #2585', 'usp_verified'),
    ('Optimum Nutrition Gold Standard 100% Whey, Double Rich Chocolate (UPC 7 48927 05226 8)', 'informed_choice'),
    ('Ritual Essential for Women, Mint Essenced', 'usp_verified'),
    ('Garden of Life Vitamin Code — Women (UPC 6 58010 11417 2)', 'other'),
    ('Kirkland Signature Extra Strength Vitamin D3 2000 IU (UPC 0 96619 39391 6)', 'usp_verified')
) as v(product_name, cert_type) on v.product_name = p.name;
