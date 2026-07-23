-- ============================================================================
-- PROVENIX — Migration 001: multi-facility manufacturer attribution
--
-- Replaces manufacturer_attributions.facility_id (exactly one facility per
-- attribution) with a join table allowing an attribution to reference 1..N
-- facilities. This lets regulatory-compliance scoring roll up across every
-- facility a manufacturer is known to operate when the specific plant can't
-- be pinned down, instead of forcing a single (possibly wrong) facility
-- guess or leaving the product with no regulatory signal at all.
--
-- is_primary marks a facility as the specific, best-evidenced site (set when
-- there's real single-facility evidence, e.g. Thorne's direct label
-- statement, Garden of Life's address match). Leave every row is_primary =
-- false when only the manufacturing COMPANY is known, not which of its
-- facilities (e.g. Nature Made / Pharmavite) — confidence then describes how
-- well-evidenced the company-level claim is, not a specific plant.
--
-- UI/display rule (not enforced in SQL): when no row is_primary, copy must
-- describe this as the manufacturer's aggregate regulatory history across
-- its known facilities — never phrased as if one specific facility's record
-- belongs to this specific product. That framing is why this design is safer
-- than picking an unverified single facility, not just more convenient.
--
-- Run this after provenix_schema.sql and provenix_seed_skus_batch1.sql.
-- ============================================================================

create table manufacturer_attribution_facilities (
    attribution_id uuid not null references manufacturer_attributions(id) on delete cascade,
    facility_id    uuid not null references facilities(id),
    is_primary     boolean not null default false,
    primary key (attribution_id, facility_id)
);

-- ----------------------------------------------------------------------------
-- Backfill: Thorne Ashwagandha — single facility, direct label match, primary
-- ----------------------------------------------------------------------------
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select ma.id, ma.facility_id, true
from manufacturer_attributions ma
join products p on p.id = ma.product_id
where p.name = 'Thorne Ashwagandha' and ma.is_current;

-- ----------------------------------------------------------------------------
-- Backfill: Garden of Life Vitamin Code — single facility, address-inferred primary
-- ----------------------------------------------------------------------------
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select ma.id, ma.facility_id, true
from manufacturer_attributions ma
join products p on p.id = ma.product_id
where p.name = 'Garden of Life Vitamin Code — Women (UPC 6 58010 11417 2)' and ma.is_current;

-- ----------------------------------------------------------------------------
-- Backfill + upgrade: Nature Made Vitamin D3 — was fully unresolved
-- (facility_id and confidence both NULL). Two of the six FDA-registered
-- Pharmavite facilities are explicitly named "Pharmavite LLC dba Nature Made"
-- in FDA's own registration data (retrieved 2026-07-22) — that IS a
-- primary-source confirmation that Pharmavite is the Nature Made brand's
-- manufacturer at the company level, distinct from the still-unresolved
-- question of which specific plant. All 6 candidate facilities are linked,
-- none marked primary, and confidence moves from NULL to 'moderate' to
-- reflect that company-level (not plant-level) confidence.
-- ----------------------------------------------------------------------------
with nm_facilities (name, address, fei_number) as (
    values
        ('Pharmavite LLC dba Nature Made', 'San Fernando, CA', '2016744'),
        ('Pharmavite LLC', '8531 Fallbrook Ave, West Hills, CA 91304', '2018618'),
        ('Pharmavite LLC', 'Valencia, CA', '2027108'),
        ('Pharmavite LLC dba Nature Made', 'Santa Clarita, CA', '3000950981'),
        ('Pharmavite LLC - Opelika', '4701 N Park Dr, Opelika, AL 36801', '3009943839'),
        ('Pharmavite LLC', '13700 Jug Street Nw, Johnstown, OH 43031', '3030170485')
),
inserted_facilities as (
    insert into facilities (name, address, country, fei_number)
    select name, address, 'US', fei_number from nm_facilities
    returning id
),
nm_attribution as (
    update manufacturer_attributions ma
    set confidence = 'moderate',
        source_type = 'inferred',
        source_detail = ma.source_detail
            || ' UPDATED 2026-07-22: two of these six facilities are explicitly named '
            || '"Pharmavite LLC dba Nature Made" in FDA''s own registration data, confirming '
            || 'Pharmavite as the manufacturer at the company level. Regulatory-compliance '
            || 'scoring now rolls up across all 6 known Pharmavite facilities via '
            || 'manufacturer_attribution_facilities rather than requiring a single-plant pin.',
        reason = 'Upgraded from fully unresolved to company-level attribution once '
            || 'manufacturer_attribution_facilities allowed rolling up regulatory signals across '
            || 'multiple candidate facilities instead of requiring one specific plant.'
    from products p
    where p.id = ma.product_id
      and p.name = 'Nature Made Vitamin D3 2000 IU (50 mcg) Softgels — Item #2585'
      and ma.is_current
    returning ma.id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select nm_attribution.id, inserted_facilities.id, false
from nm_attribution, inserted_facilities;

-- ----------------------------------------------------------------------------
-- Drop the old single-facility column now that every current attribution has
-- been migrated onto the join table.
-- ----------------------------------------------------------------------------
alter table manufacturer_attributions drop column facility_id;
