-- ============================================================================
-- PROVENIX — Backfill: Garden of Life (2011) and NOW Foods (2011) recalls
--
-- Continuation of the retailer/press recall re-check. Both confirmed absent
-- from openFDA directly: recalling_firm:"Garden of Life" returns exactly
-- the same 8 recalls already in this project's data (none from 2011);
-- recalling_firm:"NOW Foods"/"NOW Health Group" recalls in this project
-- start at 2013-07-03. Third and fourth brand (after Nature's Way) with a
-- confirmed pre-~2013 gap in openFDA's food/enforcement.json coverage --
-- a real pattern, not a one-off: openFDA's reliable coverage doesn't
-- extend fully before then, so any brand's recall history should be
-- checked against trade press for pre-2013 events, not just the API.
--
-- Garden of Life: Vitamin Code Raw Vitamin C, undeclared soy proteins (one
-- of Garden of Life's third-party manufacturers also processes soy; some
-- bottles tested positive). All lots distributed March 2009-January 2011.
-- Announced 2011-03-02 (ConsumerLab.com, nutraingredients.com, ODS FDA
-- photo archive, retrieved 2026-08-02). No FDA classification found in
-- any source checked -- left NULL.
--
-- NOW Foods: Calcium & Magnesium Softgels (US product codes 1251, 1252,
-- plus private-label versions), vitamin D overdosed 50-66x label claim
-- (30,000-40,000 IU per 3-softgel serving vs. declared 600 IU). Triggered
-- by 2 adverse event reports confirmed via lab testing, per NOW's own
-- account (SupplySide SJ, retrieved 2026-08-02). Announced 2011-06-08.
-- Health Canada classified its own recall of this product "Type II" (a
-- different regulatory system than FDA, not equivalent to an FDA Class
-- II) -- noted as context in the reason field, not entered as an FDA
-- classification. No FDA classification found in any US source checked --
-- left NULL.
-- ============================================================================

insert into recalls (brand_id, recall_date, classification, reason, status, source, openfda_ref)
select b.id, '2011-03-02'::date, null,
       'Vitamin Code Raw Vitamin C: undeclared soy proteins. One of Garden of Life''s third-party '
       || 'manufacturers also processes soy; some bottles tested positive for significant soy '
       || 'protein content. All lots distributed March 2009-January 2011. No FDA classification '
       || 'found in any source checked; not in openFDA (recalling_firm:"Garden of Life" returns '
       || 'exactly the 8 recalls already recorded here, none from 2011 -- verified 2026-08-02).',
       'closed'::record_status, 'trade_press_2011', null
from brands b where b.name = 'Garden of Life'
union all
select b.id, '2011-06-08'::date, null,
       'Calcium & Magnesium Softgels (US product codes 1251, 1252, plus private-label versions): '
       || 'vitamin D overdosed 50-66x label claim -- 30,000-40,000 IU delivered per 3-softgel '
       || 'serving vs. 600 IU declared. Triggered by 2 adverse event reports NOW confirmed via lab '
       || 'testing; company attributed it to a co-manufacturer formulation error despite correct '
       || 'specs provided. Health Canada classified its own recall of this product "Type II" (a '
       || 'different regulatory system, not an FDA classification). No FDA classification found in '
       || 'any US source checked; not in openFDA (recalling_firm:"NOW Foods"/"NOW Health Group" '
       || 'recalls in this project start at 2013-07-03 -- verified 2026-08-02).',
       'closed'::record_status, 'trade_press_2011', null
from brands b where b.name = 'NOW Foods';
