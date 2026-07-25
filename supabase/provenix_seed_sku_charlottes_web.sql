-- ============================================================================
-- PROVENIX — Seed SKU: Charlotte's Web CBD Gummies (Full Spectrum Hemp Extract)
--
-- Batch-3 candidate #4 (CBD/hemp category, new to the seed set). Notable for
-- two things: the strongest attribution evidence of any SKU seeded so far
-- (an SEC 10-K plus a label that names the identical legal entity and city),
-- and the first product using 'hemp_cbd_unclassified' (migration 003) rather
-- than force-fitting into supplement_gmp.
--
-- Attribution sources:
--   1. SEC 10-K, Charlotte's Web Holdings, Inc. (CIK 1750155, filing
--      cweb-20211231.htm, sec.gov/Archives/edgar/data/1750155/..., retrieved
--      2026-07-24): "Item 2. Properties" names "700 Tech Court, Louisville,
--      Colorado" as a leased, cGMP-designated "Manufacturing, Production,
--      Research and Development" facility (the "LOFT"), under lease to
--      "Charlotte's Web, Inc." (the operating subsidiary). Manufacturing
--      operations confirmed commencing Q3 2020.
--   2. Product label (photo reviewed directly, 2026-07-24): "Distributed by
--      CHARLOTTE'S WEB, INC. Louisville, CO 80027" — same legal entity name
--      and same city as the SEC filing, three years apart.
-- Caveat carried in `reason`, not confidence: the same 10-K states finished
-- "topical, chews, and liquid products are currently blended, flavored,
-- filled, labeled, and packaged into consumer cartons at either its
-- production facility or at contract manufacturer facilities" — so while
-- the company/facility identity is unusually well evidenced, whether this
-- specific finished gummy SKU was packaged in-house or by a third party
-- is not pinned down by either source.
--
-- No FEI number confirmed: FDA Data Dashboard (inspections_classifications,
-- LegalName variants "Charlotte's Web", "Charlotte's Web, Inc.", "Charlotte's
-- Web Holdings", "Stanley Brothers" [Charlotte's Web's original 2018
-- incorporation name, per the same 10-K], retrieved 2026-07-24) returns no
-- genuine match — the one "Stanley Brothers Inc" hit (FEI 1028257) is in
-- Louisville, KENTUCKY, not Louisville, COLORADO, and is a different,
-- unrelated company. As with prior SKUs, this endpoint only covers
-- inspected facilities, so absence is inconclusive, not contradictory.
-- ============================================================================

with brand_cw as (
    insert into brands (name, address, website)
    values (
        'Charlotte''s Web',
        'Charlotte''s Web, Inc. (operating subsidiary of the publicly traded Charlotte''s Web '
        || 'Holdings, Inc., TSX: CWEB / OTCQX: CWBHF), Louisville, CO 80027; manufacturing/R&D '
        || 'facility ("the LOFT") at 700 Tech Court, Louisville, CO, per SEC 10-K',
        'www.charlottesweb.com'
    )
    returning id
),
product_cw as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        id,
        'Charlotte''s Web CBD Gummies, Full Spectrum Hemp Extract, 15mg CBD (UPC 843119103091)',
        'hemp_cbd_unclassified',
        '{
            "servingSize": "2 gummies (8g)",
            "servingsPerContainer": 30,
            "activeIngredients": [
                {"name": "Cannabidiol (CBD) (Organic Full Spectrum Hemp Extract, aerial parts)", "amountPerServing": "15mg", "percentDV": null}
            ],
            "otherIngredients": [
                "Organic Tapioca Syrup", "Organic Cane Sugar", "Water", "Organic Tapioca Maltodextrin",
                "Organic MCT Oil", "Pectin", "Organic Natural Flavors", "Citric Acid", "Sodium Citrate",
                "Organic Sunflower Oil", "Organic Carnauba Wax", "Organic Sunflower Lecithin"
            ],
            "cbdThcProfile": {
                "totalCbdPerContainer": "<500mg",
                "thcPerServing": "0.3mg",
                "thcPerContainer": "9mg",
                "cbdToThcRatio": "57:1",
                "delta9ThcByWeight": "<0.3%",
                "hempGrownIn": ["OR", "KY", "CO"]
            }
        }'::jsonb,
        true
    from brand_cw
    returning id
),
facility_cw as (
    insert into facilities (name, address, country, fei_number)
    values (
        'Charlotte''s Web, Inc. — the LOFT',
        '700 Tech Court, Louisville, CO 80027',
        'US',
        null
    )
    returning id
),
attribution_cw as (
    insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
    select
        id,
        'high'::attribution_confidence,
        'regulatory_filing'::attribution_source,
        'SEC 10-K, Charlotte''s Web Holdings, Inc. (CIK 1750155, cweb-20211231.htm, retrieved '
        || '2026-07-24), Item 2. Properties: leased, cGMP-designated "Manufacturing, Production, '
        || 'Research and Development" facility at 700 Tech Court, Louisville, Colorado ("the LOFT"), '
        || 'under lease to operating subsidiary "Charlotte''s Web, Inc."; manufacturing operations '
        || 'confirmed commencing Q3 2020. Corroborated by the product label (photo reviewed directly, '
        || '2026-07-24): "Distributed by CHARLOTTE''S WEB, INC. Louisville, CO 80027" — identical '
        || 'legal entity name and city. FDA Data Dashboard (inspections_classifications, LegalName '
        || 'variants of "Charlotte''s Web" and "Stanley Brothers" [the company''s original 2018 '
        || 'incorporation name, per the same 10-K], retrieved 2026-07-24) returns no genuine match — '
        || 'the one "Stanley Brothers Inc" hit is a different company in Louisville, Kentucky, not '
        || 'Colorado.',
        'is_primary = true given the entity-name and city convergence between an SEC filing and the '
        || 'product label, three years apart — stronger evidence than most SKUs seeded so far. Held '
        || 'at high rather than treated as fully plant-confirmed because the same 10-K discloses that '
        || 'finished "chews" (gummies) are packaged "at either its production facility or at contract '
        || 'manufacturer facilities," without specifying which applies to any given SKU — so while '
        || 'company/facility identity is very well evidenced, in-house-vs-contract packaging for this '
        || 'specific product is not pinned down by either source.'
    from product_cw
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select attribution_cw.id, facility_cw.id, true
from attribution_cw, facility_cw;

-- ----------------------------------------------------------------------------
-- Lab testing: Tier 4, public per-lot CoA lookup via QR code on-label
-- ----------------------------------------------------------------------------
insert into lab_testing (product_id, tier, evidence, source, last_verified)
select
    id,
    'public_per_lot_lookup'::lab_testing_tier,
    'Product label (photo reviewed directly, 2026-07-24) carries a QR code captioned "Scan for the '
    || 'CoA" — a public, per-lot CoA lookup mechanism printed directly on the label. Corroborated by '
    || 'SEC 10-K testing detail (retrieved 2026-07-24): "batch tested both internally and by '
    || 'third-party laboratories for cannabinoid potency, residual solvents, heavy metals, and '
    || 'pesticides"; products also tested for identity, microbial contaminants, and aflatoxin. '
    || 'Company holds ISO 17025 lab accreditation (January 2022, per the same 10-K).',
    'label_review',
    now()
from products
where name = 'Charlotte''s Web CBD Gummies, Full Spectrum Hemp Extract, 15mg CBD (UPC 843119103091)';

-- ----------------------------------------------------------------------------
-- Certification: NSF dietary supplement certification, per SEC 10-K.
-- Logged claimed_unverified pending direct nsf.org confirmation, despite the
-- SEC-filing source being stronger than a typical marketing claim (legal
-- liability for false statements in a 10-K) — per Aaron's call, still verify
-- at the certifier's own site before marking active.
-- Note: "Certified Organic by QAI" also appears on-label but is an organic-
-- farming certification, not a supplement-quality/testing cert your
-- certification_type enum is meant to track — skipped, consistent with
-- skipping B Corp marks on Vital Proteins/OLLY.
-- ----------------------------------------------------------------------------
insert into certifications (product_id, cert_type, status, source, last_verified)
select
    id,
    'nsf_ansi_173'::certification_type,
    'claimed_unverified',
    'SEC 10-K (Charlotte''s Web Holdings, Inc., cweb-20211231.htm, retrieved 2026-07-24): "In 2020, '
    || 'the Company was the first hemp extract company to receive an NSF certification. NSF '
    || 'International''s dietary supplements certification is the only national standard that '
    || 'establishes requirements for the ingredients in dietary and nutritional supplements..." — '
    || 'reads as NSF/ANSI 173. Not yet verified at nsf.org.',
    now()
from products
where name = 'Charlotte''s Web CBD Gummies, Full Spectrum Hemp Extract, 15mg CBD (UPC 843119103091)';
