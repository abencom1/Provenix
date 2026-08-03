-- ============================================================================
-- PROVENIX — Backfill: 2002 Nature's Way Nettle lead-contamination recall
--
-- Surfaced by Aaron after the initial seed (see provenix_seed_sku_
-- natures_way_elderberry.sql), which claimed zero recalls attributable to
-- the brand after excluding a sister-name collision. That claim was
-- accurate for what openFDA's food/enforcement.json covers, but incomplete:
-- this recall predates openFDA's own database entirely -- both
-- recalling_firm:"Nature's Way Products" and "Nature's Way Products Inc"
-- return NOT_FOUND from the live API (verified 2026-08-02), not just zero
-- results within a date range. openFDA's food-enforcement coverage doesn't
-- reach back to 2002. A real reminder that "not in openFDA" and "didn't
-- happen" aren't the same thing -- worth checking press coverage for older
-- brands, not just the API, going forward.
--
-- Source: SupplySide SJ / Natural Products Insider (contemporary trade
-- press, retrieved 2026-08-02), cross-checked against ConsumerLab.com and
-- Deseret News coverage from the same week. Recalling firm: "Nature's Way
-- Products Inc." (matches the FEI 3012631639 facility already linked --
-- same brand, not another name collision). Product: Nettle capsules
-- (a different product line than the seeded Sambucus Elderberry Gummy),
-- 100-count bottles, lots 131237, 131238, 140738, 215229, distributed
-- nationwide Oct 2001-May 2002. Cause: excessive lead traced to a single
-- raw-material batch, identified via random testing by the California
-- Attorney General's office. No FDA classification (Class I/II/III) found
-- in any source checked -- left NULL rather than guessed, per this
-- project's own "blank beats guessed" rule. No consumer health problems
-- were reported per the contemporary coverage.
-- ============================================================================

insert into recalls (brand_id, recall_date, classification, reason, status, source, openfda_ref)
select b.id, '2002-06-28'::date, null,
       'Excessive lead contamination in Nettle capsules (100-count bottles, green lids), lots '
       || '131237, 131238, 140738, and 215229, distributed nationwide Oct 2001-May 2002. Traced to '
       || 'a single batch of raw material. Identified via random testing by the California Attorney '
       || 'General''s office; no consumer health problems reported. Not in openFDA (database '
       || 'coverage doesn''t reach back to 2002) -- classification not stated in any contemporary '
       || 'source checked (SupplySide SJ, Natural Products Insider, ConsumerLab.com, Deseret News).',
       'closed'::record_status, 'trade_press_2002', null
from brands b where b.name = 'Nature''s Way';
