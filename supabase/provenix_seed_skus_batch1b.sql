-- ============================================================================
-- PROVENIX — Seed SKU batch 1b: SKU #10, the genuinely unresolved case
--
-- Run this after provenix_migration_001_attribution_facilities.sql (needs the
-- manufacturer_attribution_facilities join table to exist).
--
-- FGO Organic Ashwagandha Root Powder — zero candidate facilities found at
-- all. Distinct from SKU #1 (Nature Made): that one has 6 known candidate
-- facilities under an ambiguous company match. This one has none — no FDA
-- facility is registered under "FGO," and the label discloses only a bare
-- "FGO, Seattle, WA 98117" distributor line with no legal entity suffix.
-- Sourced from provenix_seed_sku_findings.md, retrieved 2026-07-22.
-- ============================================================================

with brand_fgo as (
    insert into brands (name, address, website)
    values (
        'FGO',
        'FGO, Seattle, WA 98117, USA',
        'www.FGOrganics.com'
    )
    returning id
),
product_10 as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        id,
        'FGO Organic Ashwagandha Root Powder (16oz)',
        'supplement_gmp',
        '{
            "servingSize": "not specified on listing",
            "activeIngredients": [
                {"name": "Ashwagandha Root Powder (Withania somnifera), Organic", "amountPerServing": null, "percentDV": null}
            ],
            "otherIngredients": []
        }'::jsonb,
        true
    from brand_fgo
    returning id
)
insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
select
    id,
    null,
    null,
    'Amazon listing (amazon.com/dp/B01D9OS7MG, retrieved 2026-07-22): no manufacturer/distributor '
    || 'info on the page, no third-party certifications. DSLD label record (id 265392, '
    || 'dsldapi.od.nih.gov, retrieved 2026-07-22) lists distributor as "FGO, Seattle, WA 98117" — '
    || 'no street address, no legal entity suffix. FDA Data Dashboard (inspections_classifications, '
    || 'LegalName=FGO, retrieved 2026-07-22) returns zero results — no FDA-registered facility '
    || 'exists under this name.',
    'No candidate facility exists to link, unlike SKU #1 (Pharmavite, 6 candidates). This is a '
    || 'genuine "insufficient data" case, not attribution ambiguity — left with zero rows in '
    || 'manufacturer_attribution_facilities.'
from product_10;
