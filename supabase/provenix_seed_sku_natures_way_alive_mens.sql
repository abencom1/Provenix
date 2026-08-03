-- ============================================================================
-- PROVENIX — Seed SKU: Nature's Way Alive! Men's Complete Multivitamin,
-- 130 Tablets
--
-- 30-SKU push, candidate #6 (a second multivitamin attribution pattern,
-- distinct from Garden of Life/Ritual). Reuses the existing Nature's Way
-- brand and facility (see provenix_seed_sku_natures_way_elderberry.sql --
-- FEI 3012631639, Green Bay, WI) rather than re-researching: label
-- (photographed directly by Aaron, retrieved 2026-08-03) reads "©2024
-- Distributed by Nature's Way Brands, LLC. Green Bay, WI 54311 USA" --
-- same entity/address already linked. Recalls (0, after excluding the
-- Nature's Way Farms/Pure Water Systems sister-name collisions) and
-- adverse events (100 reports) already roll up automatically via the
-- shared brand_id -- no new brand-level research needed here.
--
-- Label transcription note: the Supplement Facts panel wraps around a
-- curved bottle across multiple overlapping photos. An initial pass
-- misread Magnesium as "105 mcg" (physiologically implausible against its
-- 25% DV -- would require a ~420mg base, i.e. mg not mcg); confirmed as
-- "105 mg" against a second, clearer/rotated photo before entry, same
-- verify-before-entering discipline as the AG1 Zinc/Selenium correction.
--
-- Ingredient modeling: Lycopene (600 mcg), Boron (150 mcg), and FloraGLO
-- Lutein Carotenoid (100 mcg) are separate, individually-quantified line
-- items on the label, NOT part of the "Superfood Antioxidant Powder
-- Blend" -- confirmed by their distinct indentation/line placement across
-- the clearer photo set. Only the named blend itself (Pomegranate
-- Extract, Carrot, Blueberry, Spinach, Apple Extract; 50 mg total,
-- providing the "10 mg Polyphenols" claimed on the front label) has
-- undisclosed individual component amounts.
--
-- No ndi_flags row: all ingredients (standard vitamins/minerals, FloraGLO
-- lutein, lycopene, boron, common fruit/vegetable extracts) are long-
-- established, not novel.
-- ============================================================================

with existing_natures_way_brand as (
    select id from brands where name = 'Nature''s Way'
),
existing_natures_way_facility as (
    select id from facilities where fei_number = '3012631639'
),
product_alive_mens as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        existing_natures_way_brand.id,
        'Nature''s Way Alive! Men''s Complete Multivitamin, 130 Tablets',
        'supplement_gmp',
        '{
            "servingSize": "1 Tablet",
            "servingsPerContainer": 130,
            "activeIngredients": [
                {"name": "Vitamin A (as 70% [630 mcg] retinyl acetate, 30% [270 mcg] beta-carotene)", "amountPerServing": "900 mcg", "percentDV": "100%"},
                {"name": "Vitamin C (as ascorbic acid)", "amountPerServing": "135 mg", "percentDV": "150%"},
                {"name": "Vitamin D3 (as cholecalciferol)", "amountPerServing": "40 mcg", "percentDV": "200%"},
                {"name": "Vitamin E (as d-alpha tocopheryl acetate)", "amountPerServing": "22.5 mg", "percentDV": "150%"},
                {"name": "Vitamin K (as phytonadione)", "amountPerServing": "120 mcg", "percentDV": "100%"},
                {"name": "Thiamin (as thiamin mononitrate)", "amountPerServing": "2.4 mg", "percentDV": "200%"},
                {"name": "Riboflavin", "amountPerServing": "2.6 mg", "percentDV": "200%"},
                {"name": "Niacin (as niacinamide)", "amountPerServing": "24 mg", "percentDV": "150%"},
                {"name": "Vitamin B6 (as pyridoxine HCl)", "amountPerServing": "4.25 mg", "percentDV": "250%"},
                {"name": "Folate (as 400 mcg DFE, 240 mcg Folic Acid)", "amountPerServing": "400 mcg DFE", "percentDV": "100%"},
                {"name": "Vitamin B12 (as cyanocobalamin)", "amountPerServing": "18 mcg", "percentDV": "750%"},
                {"name": "Biotin", "amountPerServing": "30 mcg", "percentDV": "100%"},
                {"name": "Pantothenic Acid (as D-calcium pantothenate)", "amountPerServing": "7.5 mg", "percentDV": "150%"},
                {"name": "Calcium (as calcium carbonate)", "amountPerServing": "130 mg", "percentDV": "10%"},
                {"name": "Iodine (as potassium iodide)", "amountPerServing": "150 mcg", "percentDV": "100%"},
                {"name": "Magnesium (as magnesium oxide)", "amountPerServing": "105 mg", "percentDV": "25%"},
                {"name": "Zinc (as zinc oxide)", "amountPerServing": "16.5 mg", "percentDV": "150%"},
                {"name": "Selenium (as sodium selenate)", "amountPerServing": "96 mcg", "percentDV": "175%"},
                {"name": "Copper (as copper sulfate)", "amountPerServing": "0.9 mg", "percentDV": "100%"},
                {"name": "Manganese (as manganese sulfate)", "amountPerServing": "2.3 mg", "percentDV": "100%"},
                {"name": "Molybdenum (as sodium molybdate)", "amountPerServing": "45 mcg", "percentDV": "100%"},
                {"name": "Lycopene", "amountPerServing": "600 mcg", "percentDV": null},
                {"name": "Boron (as sodium borate)", "amountPerServing": "150 mcg", "percentDV": null},
                {"name": "FloraGLO Lutein Carotenoid (from Aztec Marigold [flower] Extract)", "amountPerServing": "100 mcg", "percentDV": null}
            ],
            "proprietaryBlends": [
                {
                    "name": "Superfood Antioxidant Powder Blend",
                    "components": ["Pomegranate Extract", "Carrot", "Blueberry", "Spinach", "Apple Extract"],
                    "note": "50 mg total, provides the \"10 mg Polyphenols per serving\" claimed on the front label; individual component amounts not disclosed"
                }
            ],
            "otherIngredients": ["cellulose", "gelatin", "sodium croscarmellose", "hydroxypropyl cellulose", "stearic acid", "hypromellose", "glycerin", "magnesium stearate", "silica"]
        }'::jsonb,
        true
    from existing_natures_way_brand
    returning id
),
attribution_alive_mens as (
    insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
    select
        id,
        'high'::attribution_confidence,
        'user_photo'::attribution_source,
        'Label (photographed directly by Aaron, retrieved 2026-08-03): "©2024 Distributed by Nature''s '
        || 'Way Brands, LLC. Green Bay, WI 54311 USA." Same entity and address already linked to this '
        || 'brand''s existing attribution (FEI 3012631639).',
        'Same manufacturer as the already-seeded Nature''s Way Sambucus Elderberry Gummy -- reuses '
        || 'the existing high-confidence, single-facility attribution rather than treating this as a '
        || 'new unresolved case.'
    from product_alive_mens
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select attribution_alive_mens.id, existing_natures_way_facility.id, true
from attribution_alive_mens, existing_natures_way_facility;

with p as (select id from products where name = 'Nature''s Way Alive! Men''s Complete Multivitamin, 130 Tablets')
insert into lab_testing (product_id, tier, evidence, source, last_verified)
select p.id, 'coa_not_per_lot'::lab_testing_tier,
       'Same naturesway.com "Know What''s In Your Bottle" tool as the Sambucus Elderberry Gummy -- '
       || 'searchable by product name/SKU/ingredient, real identity/purity/potency/composition/'
       || 'contaminants testing results, but not searchable by the lot number printed on a specific '
       || 'bottle.',
       'web_research', now()
from p;
