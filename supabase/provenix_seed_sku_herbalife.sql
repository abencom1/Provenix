-- ============================================================================
-- PROVENIX — Seed SKU: Herbalife Kids Immune Health + Multivitamin Gummies
--
-- Batch-3 candidate #6 (MLM brand, new to the seed set; also first
-- children's-category product). Legal entity: Herbalife Nutrition Ltd., a
-- Cayman Islands exempted company.
--
-- Attribution: SEC 10-K, FY2025 (filed 2026, ir.herbalife.com, accession
-- 0001193125-26-057113, retrieved 2026-07-24), Item 2. Properties, names 4
-- manufacturing facilities directly (not inferred from a legal-name sweep):
--   - Winston-Salem, NC — OWNED, ~800,000 sq ft, explicitly called out as
--     the company's manufacturing flagship
--   - Lake Forest, CA — leased, ~166,000 sq ft, warehouse/manufacturing/office
--   - Changsha, Hunan, China — leased, ~154,000 sq ft, botanical extraction
--   - Suzhou, China — leased, ~122,000 sq ft manufacturing + ~87,000 sq ft
--     warehouse
-- Cross-checked against the FY2019 10-K (filed 2020, retrieved 2026-07-24),
-- which additionally listed a Nanjing, China manufacturing facility
-- (~372,000 sq ft, lease expiring 2025) — absent entirely from the FY2025
-- filing. Used the more recent filing as authoritative per this project's
-- "last verified" principle; the Nanjing drop is itself a real, dated fact
-- about how this brand's manufacturing footprint has changed, not just
-- noise between sources.
--
-- All 4 current facilities linked as candidates, none is_primary: this is a
-- genuine company-level, multiple-plausible-plants case (like Pharmavite),
-- not the P&G pattern — unlike P&G's FDA sweep (mostly irrelevant business
-- lines), all 4 facilities here are explicitly confirmed manufacturing sites
-- by the SEC filing itself, just without a way to know which one packages
-- this specific SKU.
-- ============================================================================

with brand_herbalife as (
    insert into brands (name, address, website)
    values (
        'Herbalife Nutrition',
        'Herbalife Nutrition Ltd., a Cayman Islands exempted company; corporate offices in '
        || 'downtown Los Angeles, CA (LA Live complex), per SEC 10-K',
        'www.herbalife.com'
    )
    returning id
),
product_herbalife as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        id,
        'Herbalife Kids Immune Health + Multivitamin Gummies, 60 ct (Herbalife SKU 542K)',
        'supplement_gmp',
        '{
            "servingSize": "not yet confirmed",
            "activeIngredients": [
                {"name": "Vitamins and minerals for kids'' immune health and daily wellness (specific formulation not yet confirmed from a label)", "amountPerServing": null, "percentDV": null}
            ],
            "otherIngredients": []
        }'::jsonb,
        true
    from brand_herbalife
    returning id
),
facility_winston_salem as (
    insert into facilities (name, address, country, fei_number)
    values ('Herbalife Nutrition — Winston-Salem manufacturing facility', 'Winston-Salem, NC (~800,000 sq ft, owned)', 'US', null)
    returning id
),
facility_lake_forest as (
    insert into facilities (name, address, country, fei_number)
    values ('Herbalife Nutrition — Lake Forest facility', 'Lake Forest, CA (~166,000 sq ft, leased)', 'US', null)
    returning id
),
facility_changsha as (
    insert into facilities (name, address, country, fei_number)
    values ('Herbalife Nutrition — Changsha botanical extraction facility', 'Changsha, Hunan, China (~154,000 sq ft, leased)', 'CN', null)
    returning id
),
facility_suzhou as (
    insert into facilities (name, address, country, fei_number)
    values ('Herbalife Nutrition — Suzhou manufacturing facility', 'Suzhou, China (~122,000 sq ft manufacturing + ~87,000 sq ft warehouse, leased)', 'CN', null)
    returning id
),
attribution_herbalife as (
    insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
    select
        id,
        'high'::attribution_confidence,
        'regulatory_filing'::attribution_source,
        'SEC 10-K, FY2025 (filed 2026, accession 0001193125-26-057113, retrieved 2026-07-24), Item 2. '
        || 'Properties: names 4 manufacturing facilities directly — Winston-Salem, NC (owned, '
        || '~800,000 sq ft, explicitly the company''s manufacturing flagship), Lake Forest, CA '
        || '(leased, ~166,000 sq ft), Changsha, Hunan, China (leased, ~154,000 sq ft, botanical '
        || 'extraction), and Suzhou, China (leased, ~122,000 sq ft manufacturing + ~87,000 sq ft '
        || 'warehouse). Cross-checked against the FY2019 10-K (filed 2020, retrieved 2026-07-24), '
        || 'which additionally listed a Nanjing, China facility (~372,000 sq ft, lease expiring '
        || '2025) not present in the FY2025 filing — used the more recent filing as authoritative.',
        'All 4 current facilities linked as candidates, none is_primary: a genuine company-level, '
        || 'multiple-plausible-plants case (like Pharmavite), not the P&G pattern — unlike P&G''s '
        || 'FDA sweep (mostly irrelevant business lines), all 4 here are explicitly confirmed '
        || 'manufacturing sites by the SEC filing itself, just without a way to know which one '
        || 'packages this specific SKU.'
    from product_herbalife
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select attribution_herbalife.id, f.id, false
from attribution_herbalife,
     (
        select id from facility_winston_salem
        union all select id from facility_lake_forest
        union all select id from facility_changsha
        union all select id from facility_suzhou
     ) f;

-- ----------------------------------------------------------------------------
-- Regulatory action: FTC consent order. Deliberately thin — the only source
-- found is one undated boilerplate risk-factor line in the 10-K's
-- forward-looking-statements section. This almost certainly refers to
-- Herbalife's well-known 2016 FTC pyramid-scheme settlement, but that detail
-- (date, terms, dollar amount) has NOT been independently sourced in this
-- research session, so it is deliberately left out rather than filled in
-- from general knowledge. Flag for follow-up: find the FTC's own consent
-- order or a dated news source to complete this record.
-- ----------------------------------------------------------------------------
insert into regulatory_actions (brand_id, agency, action_type, status, summary, source, retrieved_at)
select
    id,
    'FTC',
    'consent_order',
    'active',
    'SEC 10-K (FY2025, filed 2026, retrieved 2026-07-24) forward-looking-statements section lists '
    || 'as an ongoing risk factor: "the Consent Order entered into with the FTC, the effects thereof '
    || 'and any failure to comply therewith." No date, dollar figure, or terms found in this filing — '
    || 'likely refers to Herbalife''s 2016 FTC settlement, but that has NOT been independently '
    || 'sourced here and should not be treated as confirmed until a dedicated source (FTC''s own '
    || 'consent order document, or a dated news report) is found.',
    'sec_10k_forward_looking_statements',
    now()
from brands
where name = 'Herbalife Nutrition';
