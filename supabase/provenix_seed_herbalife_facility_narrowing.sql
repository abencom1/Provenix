-- ============================================================================
-- PROVENIX — Backfill: narrow Herbalife Kids Immune Health Gummies (SKU 542K)
-- attribution from 4 candidate facilities down to Suzhou specifically
--
-- Original attribution (see provenix_seed_sku_herbalife.sql) linked all 4
-- facilities named in the FY2025 10-K's Item 2 Properties as company-level
-- candidates, since at the time there was no way to know which one packages
-- this specific SKU -- the standard rollup treatment for genuine ambiguity.
--
-- New evidence resolves the ambiguity for 3 of the 4, rather than just
-- narrowing it:
--   1. Physical label (photographed directly by Aaron, retrieved 2026-08-02,
--      LOT H326408A00, BB 04/05/2027): "Made in China" -- rules out
--      Winston-Salem, NC and Lake Forest, CA on country alone.
--   2. Herbalife IR press release ("Herbalife Breaks Ground for Extraction
--      Facility in China," ir.herbalife.com/.../detail/539, retrieved
--      2026-08-02): Changsha is a raw-extraction-only facility -- it
--      processes botanical extracts/powders and explicitly ships them
--      onward "directly to Herbalife's manufacturing facilities in Suzhou,
--      China and Lake Forest, Calif." for finishing. It does not produce
--      finished consumer products itself, so it's excluded on function, not
--      just country.
--   3. That leaves Suzhou as the only currently-linked facility consistent
--      with both the country (China) and the function (finished-goods
--      manufacturing, per its original "manufacturing + warehouse" listing
--      in the 10-K).
--
-- This is why the 3 excluded facilities are unlinked here rather than kept
-- as candidates: keeping them linked would roll their inspection/warning-
-- letter history into this SKU's regulatory_compliance score despite having
-- specific evidence they weren't involved in making it -- the inaccuracy
-- the rollup design exists to avoid, not the honest uncertainty it's meant
-- to preserve. (A cross-checked historical note, not acted on: a 2016 IR
-- release, ir.herbalife.com/.../detail/215, confirms a since-closed Nanjing
-- facility was real and substantial, corroborating the existing seed file's
-- note that Nanjing dropped out of the FY2025 10-K -- irrelevant here since
-- this SKU's date code postdates that facility's 2025 lease expiration.)
--
-- Versioned per the schema's existing pattern (see manufacturer_attributions'
-- is_current/effective_to): old attribution row closed out, new row created
-- rather than mutated in place.
-- ============================================================================

with old_attribution as (
    select ma.id, ma.product_id
    from manufacturer_attributions ma
    join products p on p.id = ma.product_id
    where p.name = 'Herbalife Kids Immune Health + Multivitamin Gummies, 60 ct (Herbalife SKU 542K)'
      and ma.is_current
),
closed as (
    update manufacturer_attributions
    set is_current = false, effective_to = now()
    where id = (select id from old_attribution)
    returning product_id
),
new_attribution as (
    insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
    select
        product_id,
        'high'::attribution_confidence,
        'user_photo'::attribution_source,
        'Physical label (photographed directly by Aaron, retrieved 2026-08-02, LOT H326408A00, BB '
        || '04/05/2027): "Formulated and distributed exclusively by: HERBALIFE INTERNATIONAL OF '
        || 'AMERICA, INC. ... Made in China." Cross-referenced against Herbalife IR press release '
        || '("Herbalife Breaks Ground for Extraction Facility in China," ir.herbalife.com/news-events/'
        || 'press-releases/detail/539, retrieved 2026-08-02), which confirms Changsha is a raw-'
        || 'extraction-only site that ships processed botanicals onward to Suzhou and Lake Forest for '
        || 'finishing, rather than producing finished consumer products itself. Of the 4 facilities '
        || 'named in the FY2025 10-K (see original attribution), Suzhou is the only one consistent '
        || 'with both the label''s country claim and a finished-goods manufacturing function.',
        'Narrows the original 4-candidate, genuinely-ambiguous attribution (SEC 10-K alone couldn''t '
        || 'say which facility packages this SKU) to Suzhou specifically, now that direct evidence '
        || 'excludes the other 3 by country (Winston-Salem, Lake Forest) or function (Changsha). '
        || 'Facility-narrowing case, not a confidence change -- still high, just resolved further.'
    from closed
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select new_attribution.id, f.id, true
from new_attribution,
     facilities f
where f.name = 'Herbalife Nutrition — Suzhou manufacturing facility';
