-- ============================================================================
-- PROVENIX — Seed SKU: Optimum Nutrition Micronized Creatine Powder,
-- Unflavored, 60 Servings (UPC 7 48927 02384 8)
--
-- 30-SKU push, candidate #3 (creatine/sports-nutrition category, previously
-- uncovered). Reuses the existing Optimum Nutrition brand and facility
-- (see provenix_seed_skus_batch2.sql #4) rather than re-researching --
-- label (photographed directly by Aaron, retrieved 2026-08-03): "MANUFACTURED
-- FOR GLANBIA PERFORMANCE NUTRITION (NA), INC. 3500 Lacey Road, Suite 1200,
-- Downers Grove, IL 60515" -- the exact same entity/address already linked
-- to FEI 3016573922. Same reuse pattern as Thorne Vitamin D reusing Thorne's
-- existing brand/facility.
--
-- Recalls and adverse events already roll up automatically via the shared
-- brand_id -- no new research needed there; this SKU inherits the Lyons
-- Magnus RTD recall finding (provenix_seed_recall_gap_backfill_batch1.sql)
-- at brand level, same as every other ON product.
--
-- Certifications: label carries "Informed Choice - Trusted by Sport" and a
-- "Banned Substance Tested" badge. Confirmed via web research (retrieved
-- 2026-08-03) as a claim specific to the standard Micronized Creatine
-- Powder (distinct from the Elite Series line, which claims the stricter
-- Informed Sport program instead) -- not just inherited from Whey's
-- verification, per the Cellucor C4 Sport/Original precedent that certs
-- don't transfer across product lines without their own confirmation.
-- Entered as claimed_unverified pending manual lookup at Informed-Choice's
-- own site, same as every other certification claim in this project.
--
-- Testing: no public per-lot CoA lookup found (retrieved 2026-08-03) --
-- same claimed_no_public_coa tier as ON Whey.
--
-- No ndi_flags row: creatine monohydrate is a long-established, extremely
-- common sports-nutrition ingredient, not novel.
-- ============================================================================

with existing_on_brand as (
    select id from brands where name = 'Optimum Nutrition'
),
existing_on_facility as (
    select id from facilities where fei_number = '3016573922'
),
product_on_creatine as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        existing_on_brand.id,
        'Optimum Nutrition Micronized Creatine Powder, Unflavored, 60 Servings (UPC 7 48927 02384 8)',
        'supplement_gmp',
        '{
            "servingSize": "5 g (1 Rounded Teaspoon)",
            "servingsPerContainer": 60,
            "activeIngredients": [
                {"name": "Creatine Monohydrate", "amountPerServing": "5 g", "percentDV": null}
            ],
            "otherIngredients": []
        }'::jsonb,
        true
    from existing_on_brand
    returning id
),
attribution_on_creatine as (
    insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
    select
        id,
        'high'::attribution_confidence,
        'user_photo'::attribution_source,
        'Label (photographed directly by Aaron, retrieved 2026-08-03): "Manufactured for Glanbia '
        || 'Performance Nutrition (NA), Inc. 3500 Lacey Road, Suite 1200, Downers Grove, IL 60515." '
        || 'Exact same entity and address already linked to this brand''s existing attribution (FEI '
        || '3016573922, "Glanbia Performance Nutrition Manufacturing Inc") -- reusing that facility '
        || 'rather than re-deriving it.',
        'Same manufacturer as the already-seeded Optimum Nutrition Whey product -- reuses the '
        || 'existing high-confidence, single-facility attribution rather than treating this as a '
        || 'new unresolved case.'
    from product_on_creatine
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select attribution_on_creatine.id, existing_on_facility.id, true
from attribution_on_creatine, existing_on_facility;

insert into lab_testing (product_id, tier, evidence, source, last_verified)
select p.id, 'claimed_no_public_coa'::lab_testing_tier,
       'Optimum Nutrition requires vendor CoAs for raw materials and claims in-house/independent lab '
       || 'verification; no public per-lot CoA lookup tool found for this product.',
       'web_research', now()
from product_on_creatine p;

insert into certifications (product_id, cert_type, status, source, last_verified)
select p.id, 'informed_choice'::certification_type, 'claimed_unverified', 'label_claim_informed_choice', now()
from product_on_creatine p;
