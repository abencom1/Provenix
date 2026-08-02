-- ============================================================================
-- PROVENIX — Backfill: recalls, adverse events, and lab testing for Herbalife
--
-- Herbalife was seeded (batch-3) with attribution + the FTC consent order
-- only; recalls, adverse events, testing, and certifications were never
-- researched. Surfaced by a post-hoc sanity audit of all 21 seed products'
-- trust_scores: Herbalife ranked #1 overall (93/100) on just 2 of 6
-- subscores, outranking every fully-documented clean brand in the set
-- despite the active FTC action already being factored in. Closing the
-- recalls/adverse-events/testing gap is the direct fix; ingredient
-- transparency and certifications remain open (see below).
--
-- Recalls (openFDA food/enforcement.json, search=recalling_firm:"Herbalife",
-- retrieved 2026-08-02): linked to brand_id, not product_id — none of these
-- 4 recalls match the seeded Kids Immune Health Gummies SKU specifically
-- (Protein Bar, Relaxation Tea, Protein Bar Deluxe, Formula 1 Shake Mix),
-- same brand-level-rollup reasoning as provenix_seed_recalls_batch1.sql.
-- All 4 "Herbalife International Of America Inc" / "Herbalife International
-- of America" — the brand's own US entity, not a sister-brand mixup.
--
-- Adverse events (openFDA CAERS food/event.json, search=products.name_brand:
-- "Herbalife" AND products.role:"SUSPECT", retrieved 2026-08-02): same
-- pipeline as provenix_seed_recalls_adverse_events_batch2.sql. CAERS
-- disclaimer applies (§12.2) — no causal relationship implied.
--
-- Lab testing (retrieved 2026-08-02): Herbalife's own site ("What is
-- Herbalife's commitment to quality?" FAQ; "Testing our products" article)
-- claims ISO 17025-accredited labs and 300,000+ tests/year using
-- HPLC/LC-MS/MS/GC/ICP-MS — real, sourced, but company-wide and not a
-- public per-lot CoA lookup, same claimed_no_public_coa tier as most of
-- the existing seed set.
--
-- Still open, deliberately not filled in here (see feedback-provenix-
-- verification-role — no guessing from summaries):
--   - ingredient_transparency: the Kids Immune Health Gummies (SKU 542K)
--     Supplement Facts panel is not in DSLD and the herbalife.com product
--     page is JS-rendered (not fetchable). Only a marketing fragment
--     surfaced ("2 gummies = 20% DV Vitamin D"), not a full panel — not
--     enough to enter honestly.
--   - certifications: found NSF Certified for Sport on Herbalife's sports-
--     nutrition line and a general "certified gluten-free" support article,
--     but could not confirm either applies to this specific SKU (per the
--     Cellucor C4 Original precedent, a cert on a different product line
--     doesn't count). No row inserted.
-- Both need a physical label check or a JS-capable browser session.
-- ============================================================================

with b as (select id from brands where name = 'Herbalife Nutrition'),
     p as (select id from products where name = 'Herbalife Kids Immune Health + Multivitamin Gummies, 60 ct (Herbalife SKU 542K)')
insert into recalls (brand_id, recall_date, classification, reason, status, source, openfda_ref)
select b.id, v.recall_date::date, v.classification, v.reason, 'closed'::record_status,
       'openfda_food_enforcement', v.openfda_ref
from b, (values
    ('2013-03-13', 'Class I', 'Herbalife of America Inc is initiating this recall due to trace amounts of an undeclared milk protein allergen. (Formula 1 Instant Healthy Meal, Nutritional Shake Mix, Vanilla Dream)', 'F-1059-2013'),
    ('2022-03-23', 'Class II', 'Undeclared allergen - egg. (Protein Bar Deluxe, Chocolate Peanut)', 'F-0860-2022'),
    ('2025-07-30', 'Class II', 'Incorrect ingredient was received from supplier and used in manufacturing finished product Relaxation Tea.', 'H-0390-2025'),
    ('2017-05-24', 'Class III', 'Herbalife is recalling Protein Bar-Peanut Butter because it may contain a trace amount of fish gelatin.', 'F-2239-2017')
) as v(recall_date, classification, reason, openfda_ref)
;

with b as (select id from brands where name = 'Herbalife Nutrition')
insert into adverse_event_counts (brand_id, report_count, data_period, source)
select b.id, 236, 'cumulative through 2026-08-02', 'openfda_hfcs'
from b;

with p as (select id from products where name = 'Herbalife Kids Immune Health + Multivitamin Gummies, 60 ct (Herbalife SKU 542K)')
insert into lab_testing (product_id, tier, evidence, source, last_verified)
select p.id, 'claimed_no_public_coa'::lab_testing_tier,
       'Herbalife''s own site claims ISO 17025-accredited labs and 300,000+ tests/year using HPLC, '
       || 'LC-MS/MS, GC, and ICP-MS ("What is Herbalife''s commitment to quality?" FAQ; "Testing our '
       || 'products" article, herbalife.com, retrieved 2026-08-02). Company-wide claim, not scoped to '
       || 'this SKU; no public per-lot CoA lookup tool found.',
       'web_research', now()
from p;
