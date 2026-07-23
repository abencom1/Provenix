-- ============================================================================
-- PROVENIX — Backfill: link Garden of Life's remaining 2 candidate facilities
--
-- Standard going forward (see project memory): whenever manufacturer
-- attribution is ambiguous among N candidate facilities, ALL N get inserted
-- into facilities and linked via manufacturer_attribution_facilities —
-- is_primary = true on the best-evidenced one if any, false on the rest.
-- Never store only the primary pick and drop the other real candidates,
-- since any of them getting a future warning letter/inspection finding
-- should still roll up into this product's regulatory-compliance signal.
--
-- Garden of Life originally only got its primary facility (West Palm Beach,
-- FEI 3011330545) linked. Backfilling the other 2 found during #7's research
-- (provenix_seed_sku_findings.md) to match Nature Made's pattern.
-- ============================================================================

with gol_attribution as (
    select ma.id as attribution_id
    from manufacturer_attributions ma
    join products p on p.id = ma.product_id
    where p.name = 'Garden of Life Vitamin Code — Women (UPC 6 58010 11417 2)' and ma.is_current
),
new_facilities (name, address, fei_number) as (
    values
        ('Garden of Life', '1335 53rd St, Mangonia Park, FL 33407', '3010543257'),
        ('Garden Of Life Llc', '114 Tri County Dr, Freedom, PA 15042', '3011711592')
),
inserted_facilities as (
    insert into facilities (name, address, country, fei_number)
    select name, address, 'US', fei_number from new_facilities
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select gol_attribution.attribution_id, inserted_facilities.id, false
from gol_attribution, inserted_facilities;
