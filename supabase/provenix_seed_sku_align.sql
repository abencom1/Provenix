-- ============================================================================
-- PROVENIX — Seed SKU: Align Probiotic (Procter & Gamble brand)
--
-- Batch-3 candidate #1 (probiotic category, new to the seed set). Genuinely
-- unresolved manufacturer case, distinct in kind from FGO (batch1b): FGO had
-- no FDA-registered facility under its name at all, so there was nothing to
-- exclude. Align's label consistently reads "Distributed by P&G" across every
-- product image reviewed — a specific labeling signal (distinct from
-- "manufactured by") that the named party is NOT the manufacturer, and the
-- true manufacturer goes undisclosed. FDA Data Dashboard
-- (inspections_classifications, LegalName variants of "Procter & Gamble",
-- retrieved 2026-07-24) returns 25+ FEI-registered facilities under that
-- legal name, but they span unrelated P&G business lines (hair care, paper
-- products, distribution centers) with no way to identify which, if any,
-- makes Align — so none are linked as candidates. Brand ownership confirmed
-- via P&G's own newsroom press release (us.pg.com, dated 2026-06-17).
-- Sourced from alignprobiotics.com (retrieved 2026-07-24), Amazon listing
-- ASIN B08B7BWHJ8 (retrieved 2026-07-24), and label images reviewed directly.
-- ============================================================================

with brand_align as (
    insert into brands (name, address, website)
    values (
        'Align',
        'Distributed by Procter & Gamble, Cincinnati, OH (no street address disclosed on label)',
        'www.alignprobiotics.com'
    )
    returning id
),
product_align as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        id,
        'Align Probiotic Digestive Support Supplement, 84 ct capsules '
        || '(UPC 037000609537 / GTIN 00037000609537)',
        'supplement_gmp',
        '{
            "servingSize": "1 capsule",
            "activeIngredients": [
                {"name": "Bifidobacterium 35624 (probiotic strain)", "amountPerServing": null, "percentDV": null}
            ],
            "otherIngredients": []
        }'::jsonb,
        true
    from brand_align
    returning id
)
insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
select
    id,
    null,
    null,
    'Label images (reviewed directly, 2026-07-24): every Align product image reads "Distributed by '
    || 'P&G" / "Distributed by Procter & Gamble, Cincinnati, OH" — no manufacturer named, no facility '
    || 'address. P&G brand ownership corroborated by P&G newsroom press release '
    || '(us.pg.com/newsroom/news-releases/..., dated 2026-06-17). FDA Data Dashboard '
    || '(inspections_classifications, LegalName="Procter & Gamble" and variants, retrieved 2026-07-24) '
    || 'returns 25+ distinct FEI numbers under that legal name (e.g. The Procter & Gamble Manufacturing '
    || 'Company, Procter & Gamble Distributing LLC, Procter & Gamble Hair Care LLC, Procter & Gamble '
    || 'Manufacturing GmbH), spanning hair care, paper products, and distribution-center operations with '
    || 'no supplement-specific entry and no way to identify which (if any) makes Align.',
    'Label uses "distributed by," not "manufactured by" — a specific 21 CFR 101.5 signal that the named '
    || 'party is not the manufacturer. Because P&G''s FDA-registered facilities span entirely unrelated '
    || 'business lines with no supplement-specific candidate, none are linked in '
    || 'manufacturer_attribution_facilities: unlike Nature Made/Pharmavite (6 plausible candidates, all '
    || 'in the supplement business), P&G''s legal-name match does not discriminate between its unrelated '
    || 'business lines, so listing any of them as a candidate would overstate what is actually known. '
    || 'Genuine "insufficient data," left with zero rows.'
from product_align;

insert into lab_testing (product_id, tier, evidence, source, last_verified)
select
    id,
    'claimed_no_public_coa'::lab_testing_tier,
    'Brand states "Each lot is DNA tested to ensure it contains our unique strain" (alignprobiotics.com, '
    || 'retrieved 2026-07-24) — a testing claim with no public per-lot CoA lookup tool found.',
    'web_research',
    now()
from products
where name like 'Align Probiotic Digestive Support Supplement%';

-- No certifications insert: no NSF/USP/Informed Sport/Informed Choice badge or claim found on
-- alignprobiotics.com or the Amazon/BJ's listings reviewed.
