-- ============================================================================
-- PROVENIX — Seed SKU: Spindle Muscle+ (Spindle / Samyang Roundsquare)
--
-- Batch-4 candidate #1, picked specifically to exercise `ndi_flags`, which
-- had zero rows across all 20 prior seed SKUs despite the table/RLS existing
-- since migration 005. Genuinely novel active ingredient: Akkermansia MYO™,
-- a pasteurized (postbiotic) Akkermansia muciniphila strain, in a brand-new
-- product (Spindle launched July 2026).
--
-- NDI identity chain, verified from primary sources (not asserted from
-- memory or search-engine summaries — see feedback-provenix-verification-role):
--   1. HealthBiome's own pipeline page (en.healthbiome.co.kr/gwbbs/gw_page6.php
--      ?ti=cate2&me_co=2010, retrieved 2026-07-28) states directly:
--      "SPINDLE MUSCLE+ Powered by HB05P (Akkermansia MYO™)" — confirming
--      Akkermansia MYO is HealthBiome's HB05P under its Spindle-facing trade
--      name, not a separate/unnotified strain.
--   2. HB05P is the subject of NDIN 1438: FDA acknowledgment-without-objection
--      letter dated 2025-12-10 (docket FDA-2025-S-0023-0133, signed by Betsy
--      Jean Yakes, Chief, Identity and Status Branch, Division of Research
--      and Evaluation — PDF retrieved directly by Aaron from regulations.gov,
--      not sourced from a press release), plus a clarifying follow-up letter
--      dated 2025-12-16 correcting a units typo (CFU/day -> cells/day).
--      Conditions of use: one serving/day, max 150 mg (3.0-3.6x10^10
--      cells/day), adults >18, excluding lactating/pregnant women.
--   3. Identity (Akkermansia MYO = HB05P = the ingredient in Spindle Muscle+)
--      confirmed directly by Aaron, 2026-07-28.
--
-- Manufacturer attribution is genuinely unresolved: us.spindle.bio's product
-- page (retrieved 2026-07-27/28) has no "manufactured by"/"distributed by"
-- statement and no facility address anywhere, including the footer. Spindle
-- is a brand under Samyang Roundsquare (Korea-based; Spindle brand launched
-- July 2026 per contemporaneous trade press: nutritioninsight.com,
-- newswise.com), but no FDA Data Dashboard lookup for Samyang-affiliated FEI
-- facilities has been run yet — left as a follow-up, not fabricated here.
-- Weaker than Align's case: Align at least had an explicit "distributed by"
-- 21 CFR 101.5 signal; Spindle discloses no distributor/manufacturer
-- statement of any kind.
--
-- No third-party testing or certification claim found on the product page
-- (retrieved 2026-07-28) -> lab_testing Tier 1, no certifications row.
-- ============================================================================

with brand_spindle as (
    insert into brands (name, address, website)
    values (
        'Spindle',
        'Brand under Samyang Roundsquare (Korea-based); no specific facility or '
        || 'distributor address disclosed on the product page. US launch, July 2026.',
        'us.spindle.bio'
    )
    returning id
),
product_spindle as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        id,
        'Spindle Muscle+ (Akkermansia MYO(TM) postbiotic capsules)',
        'supplement_gmp',
        '{
            "servingSize": "1 capsule daily (exact capsule count/serving not disclosed on product page)",
            "activeIngredients": [
                {"name": "Akkermansia MYO (TM) (HB05P, Pasteurized Akkermansia muciniphila)", "amountPerServing": null, "percentDV": null}
            ],
            "otherIngredients": []
        }'::jsonb,
        true
    from brand_spindle
    returning id
)
insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
select
    id,
    null,
    null,
    'us.spindle.bio product page (retrieved 2026-07-27/28): no "manufactured by," "distributed by," or '
    || 'facility address text found anywhere, including the site footer ("(c) 2026 Spindle. All rights '
    || 'reserved" only). Spindle is reported in trade press (nutritioninsight.com, newswise.com; both '
    || 'July 2026) as a brand launched by Samyang Roundsquare (Korea-based), but no FDA Data Dashboard '
    || 'lookup for Samyang-affiliated FEI facilities has been run yet.',
    'Genuinely unresolved, and weaker than Align''s case: Align''s label at least carried an explicit '
    || '"distributed by P&G" 21 CFR 101.5 signal (a specific fact about who is NOT the manufacturer). '
    || 'Spindle discloses no distributor or manufacturer statement of any kind on the reviewed page, so '
    || 'there is nothing yet to even exclude a candidate facility by. Left with zero linked rows in '
    || 'manufacturer_attribution_facilities rather than guessing from the Samyang parent name alone.'
from product_spindle;

insert into ndi_flags (product_id, ingredient, expected_notification, notification_found, note, source, retrieved_at)
select
    id,
    'Akkermansia MYO (TM) (HB05P, Pasteurized Akkermansia muciniphila)',
    true,
    true,
    'Akkermansia muciniphila is a genuinely novel dietary ingredient (multiple unrelated strains have '
    || 'required their own NDI notifications: NDI 1326 ADM-Deerland, NDI 1363/1438 HealthBiome HB05P, '
    || 'NDI 1468 AKK PROBIO/Thankcome-Maypro, CJ BIO BiomeNrich POST M005) -- an NDI notification was '
    || 'expected for this ingredient rather than assumed exempt. HealthBiome''s own site names '
    || '"SPINDLE MUSCLE+ Powered by HB05P (Akkermansia MYO(TM))" directly, confirming Akkermansia MYO is '
    || 'HB05P''s Spindle-facing trade name, not a separate unnotified strain. HB05P is covered by NDIN '
    || '1438 (FDA acknowledgment-without-objection letter, 2025-12-10, docket FDA-2025-S-0023-0133; '
    || 'clarifying follow-up letter 2025-12-16 corrected a CFU/day -> cells/day units typo). Identity '
    || '(Akkermansia MYO = HB05P = the ingredient in Spindle Muscle+) confirmed directly by Aaron, '
    || '2026-07-28, not inferred by Claude from search-engine summaries alone.',
    'HealthBiome pipeline page (en.healthbiome.co.kr/gwbbs/gw_page6.php?ti=cate2&me_co=2010, retrieved '
    || '2026-07-28) + FDA NDIN 1438 acknowledgment letter (docket FDA-2025-S-0023-0133, PDF retrieved '
    || 'directly from regulations.gov by Aaron, 2026-07-27)',
    now()
from products
where name = 'Spindle Muscle+ (Akkermansia MYO(TM) postbiotic capsules)';

insert into lab_testing (product_id, tier, evidence, source, last_verified)
select
    id,
    'no_testing_claimed'::lab_testing_tier,
    'No third-party testing claim, certification badge, or independent lab-verification statement found '
    || 'anywhere on the us.spindle.bio product page (retrieved 2026-07-28).',
    'web_research',
    now()
from products
where name = 'Spindle Muscle+ (Akkermansia MYO(TM) postbiotic capsules)';

-- No certifications insert: no NSF/USP/Informed Sport/Informed Choice badge or claim found on
-- us.spindle.bio.
