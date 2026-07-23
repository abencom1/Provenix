-- ============================================================================
-- PROVENIX — Adverse event counts for the 4 seed brands (openFDA CAERS,
-- food/event.json), retrieved 2026-07-22.
--
-- report_count = reports where products.role = "SUSPECT" for a product whose
-- products.name_brand contains the brand name — i.e. reports where this
-- brand's product was specifically implicated, not just co-mentioned as a
-- CONCOMITANT product the consumer also happened to be taking. This matches
-- CAERS's own rule (also enforced in the app display layer per schema
-- comment): no causal relationship can be drawn, and a report listing
-- several products cannot have a reaction attributed to one specific product.
--
-- Linked to brand_id, not product_id — CAERS reports reference many products
-- under each brand (e.g. "Nature Made Ultra Omega Fish Oil," "Nature Made
-- Calcium"), not specifically the 4 exact SKUs seeded so far.
--
-- No warning letters found for any of the 10 known FEI numbers (6 Pharmavite,
-- 3 Garden of Life, 1 Thorne) via FDA Data Dashboard compliance_actions —
-- genuinely zero results, so nothing to insert into warning_letters.
-- ============================================================================

with b as (
    select name, id from brands where name in ('Nature Made', 'Garden of Life', 'Thorne', 'FGO')
)
insert into adverse_event_counts (brand_id, report_count, data_period, source)
select b.id, v.report_count, 'cumulative through 2026-07-22', 'openfda_hfcs'
from b
join (values
    ('Nature Made', 497),
    ('Garden of Life', 107),
    ('Thorne', 51),
    ('FGO', 1)
) as v(brand_name, report_count) on v.brand_name = b.name;
