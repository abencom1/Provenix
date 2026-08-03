-- ============================================================================
-- PROVENIX — Backfill: Nature's Way Calcium + D3 Gummies moisture recall
-- (2020) and Sambucus Organic Elderberry Syrup voluntary withdrawal
--
-- Second and third real Nature's Way events surfaced by Aaron via retailer/
-- press links, after openFDA missed the 2002 Nettle recall too (see
-- provenix_seed_natures_way_recall_backfill.sql). Both checked against
-- openFDA directly before writing this file and confirmed absent:
--   - recalling_firm:"Nature's Way" AND report_date:[20200101 TO 20201231]
--     -> NOT_FOUND
--   - recalling_firm:"Nature's Way Products" AND report_date:[20180101 TO
--     20221231] -> NOT_FOUND
-- This is now a demonstrated, repeated pattern, not a one-off: openFDA's
-- food/enforcement.json misses real recalls/withdrawals even within its
-- normal date coverage, not just pre-2004 events. Retailer recall pages and
-- trade press are catching things the API doesn't. Worth treating as a
-- standing gap in the research process, not just a Nature's Way-specific
-- fix -- flagged to Aaron as a methodology question, not silently patched
-- everywhere on the assumption it's now handled.
--
-- #1: Calcium + D3 Gummies 60ct (UPC 0 33674 10255 8), lots 2125551,
-- 20125473, 20128098 -- moisture contamination, announced 2020-07-07 (Clark's
-- Nutrition recall notice, retrieved 2026-08-02). No FDA classification
-- found in any source checked. A different product line than the seeded
-- Sambucus Elderberry Gummy, but same brand -- brand-level rollup per
-- convention.
--
-- #2: Sambucus Organic Elderberry Syrup 4 fl oz (UPC 0 33674 15796 1),
-- lots 20191398 and 20193159 -- explicitly a "Voluntary Withdrawal," not an
-- FDA recall, for bloating bottles / pressure on opening. Company statement
-- (Natural Grocers / Good Food Store recall notices, retrieved 2026-08-02):
-- "This is not a product safety issue." classification recorded as
-- 'Voluntary Withdrawal' rather than a Class I/II/III value, to preserve
-- that distinction rather than flattening it into a formal recall. No
-- specific announcement date found in any source checked -- recall_date
-- left NULL rather than guessed from the lots' printed expiration dates
-- (late 2026), which describe shelf life, not when the withdrawal happened.
-- ============================================================================

insert into recalls (brand_id, recall_date, classification, reason, status, source, openfda_ref)
select b.id, '2020-07-07'::date, null,
       'Moisture contamination. Calcium + D3 Gummies 60ct (UPC 0 33674 10255 8), lots 2125551, '
       || '20125473, 20128098. No FDA classification found in any source checked; not in openFDA '
       || '(recalling_firm:"Nature''s Way" AND report_date:[20200101 TO 20201231] -> NOT_FOUND, '
       || 'verified 2026-08-02).',
       'closed'::record_status, 'retailer_recall_notice_2020', null
from brands b where b.name = 'Nature''s Way'
union all
select b.id, null, 'Voluntary Withdrawal',
       'Bloating bottles / noticeable pressure when opening. Sambucus Organic Elderberry Syrup '
       || '4 fl oz (UPC 0 33674 15796 1), lots 20191398 and 20193159. Company statement: "This is '
       || 'not a product safety issue." Not in openFDA (recalling_firm:"Nature''s Way Products" AND '
       || 'report_date:[20180101 TO 20221231] -> NOT_FOUND, verified 2026-08-02); no specific '
       || 'announcement date found in any retailer notice checked (Natural Grocers, Good Food Store '
       || 'Missoula) -- recall_date left NULL rather than inferred from the lots'' printed expiration '
       || 'dates (late 2026), which describe shelf life, not when the withdrawal happened.',
       'closed'::record_status, 'retailer_recall_notice', null
from brands b where b.name = 'Nature''s Way';
