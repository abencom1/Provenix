-- ============================================================================
-- PROVENIX — Seed SKU: Vega One All-in-One Nutritional Shake, French
-- Vanilla, 827g (Approx. 20 Servings)
--
-- 30-SKU push, candidate #4 (plant-based protein category, previously
-- uncovered). Legal entity: Sequel Naturals ULC (dba Vega), Burnaby, BC,
-- Canada. Ownership: WhiteWave Foods (2015) -> Danone (2016, via the
-- WhiteWave acquisition) -> WM Partners, a Florida private-equity firm
-- (2021-present) (Lexpert, Private Capital Journal, retrieved 2026-08-03).
--
-- regulatory_pathway = food_gmp, not supplement_gmp: the label (photographed
-- directly by Aaron, retrieved 2026-08-03) carries a "Nutrition Facts"
-- panel, not "Supplement Facts" -- this product is regulated as a
-- conventional food/meal-replacement, matching openFDA's own product_type
-- classification for its recalls ("Food") and CAERS industry code
-- ("Dietary Conventional Foods/Meal Replacements").
--
-- Attribution: UNRESOLVED, genuine insufficient data. Label reads
-- "Distributed by: Sequel Naturals ULC, 101-3007 Wayburne Drive, Burnaby,
-- BC V5G 4W3, Canada" -- distributor-typed, no manufacturer named. FDA
-- Data Dashboard (inspections_classifications, retrieved 2026-08-03)
-- returns zero results for "Sequel Naturals," "Sequel Naturals ULC,"
-- "Sequel Naturals Ltd," "Vega Foods," and "WM Partners" as exact legal
-- names; "Vega" alone returns 96 unrelated matches (a muffin company, a
-- cheese maker in Spain, an electronics firm in China, none in Canada or
-- in the nutrition business). As a Canadian company, Sequel Naturals may
-- sell into the US without itself appearing in FDA's domestic/foreign
-- FEI-inspection registry, even though it clearly has US recall history
-- (recalls don't require the same registration). Left with zero rows in
-- manufacturer_attribution_facilities -- per this project's own rule,
-- unresolved is a legitimate answer, not a failure. NOTE: per the min-
-- viable-score rule (scoreProductV1.ts), this means the product will NOT
-- be scorable overall despite having unusually rich regulatory data below
-- -- a real, honest case of the two being independent axes.
--
-- Recalls (openFDA food/enforcement.json, searched under both "Sequel
-- Naturals" and "Vega" as recalling_firm, retrieved 2026-08-03; cross-
-- checked against Health Canada's own Nov 1, 2013 consumer warning and a
-- GovDelivery bulletin, both corroborating the same event with no new
-- information) -- 13 total, brand-level rollup:
--   - 5x Class I (2013-06-07, event 65412): chocolate-coating cross-
--     contamination with milk allergen in "vega one"/"vega sport" bars
--     (a different product form than the seeded shake) -- one reported
--     allergic reaction.
--   - 8x Class II (2013-11-08, event 66772): trace chloramphenicol (an
--     antibiotic) from a third-party enzyme supplier, across nearly the
--     entire Vega ONE/Sport line -- INCLUDES the exact seeded flavor,
--     "Vega ONE Nutritional Shake French Vanilla" (F-1145-2014, 62,809
--     units, sizes 414g/827g/37.6g -- 827g matches this seeded product's
--     size exactly, though obviously a different, older production run).
--
-- Also found but NOT added here: a 2025-07-09 Health Canada recall
-- (RA-77706, Class 3 -- lowest hazard) for plastic contamination in Vega
-- Organic Protein + SupergreensTM Vanilla Drink Mix, a different product
-- line, distributed only online in Alberta/BC/Ontario/Quebec -- confirmed
-- via openFDA (recalling_firm:"Sequel Naturals" AND report_date:[20240101
-- TO 20261231] -> NOT_FOUND) that this never had US distribution. Left
-- out as out-of-scope for a US-focused recalls table rather than force-
-- fit a no-US-distribution foreign event; flagged here for the record.
--
-- Adverse events (openFDA CAERS, search=products.name_brand:"Vega" AND
-- products.role:"SUSPECT", retrieved 2026-08-03): 45 reports. Spot-checked
-- 10 of 10 sampled results before trusting the count given how generic
-- "Vega" is as a search term -- all classified under "Dietary Conventional
-- Foods/Meal Replacements" or "Vit/Min/Prot/Unconv Diet," confirming
-- genuine matches, not name-collision noise.
--
-- Ingredient list: the Nutrition Facts panel quantifies Protein (20g) and
-- Dietary Fiber (6g) plus %DV-only figures for 16 vitamins/minerals (no
-- absolute mg amounts given -- normal for a food-panel format, unlike a
-- Supplement Facts panel). The long ingredient list itself (pea protein,
-- flaxseed, hemp protein, sacha inchi, maca, spirulina, kale, marine algae,
-- fruit/veg blends, chlorella, probiotics, etc.) has NO individual amounts
-- disclosed anywhere -- functionally the same opacity as a proprietary
-- blend even though the label never uses that word, so it's modeled as one
-- here rather than either overstating disclosure (treating the whole list
-- as "transparent" because macros are known) or ignoring it. This yields
-- ingredient_transparency's "mixed" tier (55), which is the honest read:
-- real macro disclosure, real opacity on what's actually in the "greens
-- and superfood" blend that's the product's whole selling point.
-- ============================================================================

with brand_vega as (
    insert into brands (name, address, website)
    values (
        'Vega',
        'Sequel Naturals ULC, 101-3007 Wayburne Drive, Burnaby, BC V5G 4W3, Canada (owned by WM '
        || 'Partners since 2021; previously Danone 2016-2021, WhiteWave Foods 2015-2016)',
        'www.myvega.com'
    )
    returning id
)
insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        id,
        'Vega One All-in-One Nutritional Shake, French Vanilla, 827g (Approx. 20 Servings)',
        'food_gmp',
        '{
            "servingSize": "1 scoop (41g)",
            "servingsPerContainer": 20,
            "activeIngredients": [
                {"name": "Protein", "amountPerServing": "20 g", "percentDV": "27%"},
                {"name": "Dietary Fiber", "amountPerServing": "6 g", "percentDV": "24%"},
                {"name": "Vitamin A", "amountPerServing": null, "percentDV": "90%"},
                {"name": "Vitamin C", "amountPerServing": null, "percentDV": "70%"},
                {"name": "Calcium", "amountPerServing": null, "percentDV": "20%"},
                {"name": "Iron", "amountPerServing": null, "percentDV": "15%"},
                {"name": "Vitamin D", "amountPerServing": null, "percentDV": "50%"},
                {"name": "Vitamin E", "amountPerServing": null, "percentDV": "50%"},
                {"name": "Vitamin K", "amountPerServing": null, "percentDV": "60%"},
                {"name": "Thiamine", "amountPerServing": null, "percentDV": "50%"},
                {"name": "Riboflavin", "amountPerServing": null, "percentDV": "60%"},
                {"name": "Niacin", "amountPerServing": null, "percentDV": "50%"},
                {"name": "Vitamin B6", "amountPerServing": null, "percentDV": "50%"},
                {"name": "Folate", "amountPerServing": null, "percentDV": "50%"},
                {"name": "Vitamin B12", "amountPerServing": null, "percentDV": "15%"},
                {"name": "Biotin", "amountPerServing": null, "percentDV": "50%"},
                {"name": "Pantothenate", "amountPerServing": null, "percentDV": "50%"},
                {"name": "Phosphorus", "amountPerServing": null, "percentDV": "25%"},
                {"name": "Iodine", "amountPerServing": null, "percentDV": "2%"},
                {"name": "Magnesium", "amountPerServing": null, "percentDV": "10%"},
                {"name": "Selenium", "amountPerServing": null, "percentDV": "2%"}
            ],
            "proprietaryBlends": [
                {
                    "name": "Plant Protein / Veggies & Greens / Superfood Complex",
                    "components": [
                        "Pea Protein", "Flaxseed", "Pea Starch", "Organic Acacia Gum", "Hemp Protein",
                        "Sacha Inchi Protein", "Organic Gelatinized Maca Root", "Organic Broccoli",
                        "Inulin (from Chicory Root)", "Organic Spirulina", "Organic Kale",
                        "Organic Marine Algae", "Dried Fruit & Vegetable Blend (Spinach, Broccoli, Carrot, Beet, Tomato, Apple, Cranberry, Orange, Cherry, Blueberry, Strawberry, Mushroom)",
                        "Chlorella Vulgaris", "Papain", "Probiotics (Bacillus Coagulans)",
                        "Dried Antioxidant Fruit Blend (Grape Seed Extract, Organic Pomegranate, Acai, Mangosteen, Organic Goji, Organic Maqui)"
                    ],
                    "note": "Contributes to the 20g total protein and 6g fiber figures above; no individual ingredient amounts disclosed -- listed in descending order by weight per standard food-labeling rules, not a named/totaled supplement blend, but functionally the same opacity."
                }
            ],
            "otherIngredients": ["Natural Flavor", "Stevia Leaf Extract", "Citric Acid"]
        }'::jsonb,
        true
    from brand_vega;

-- No manufacturer_attributions row: genuinely unresolved (see comment
-- above). No facility row, no attribution row -- consistent with how
-- Align, OLLY, Ritual, Kirkland, Spring Valley, and Cellucor are handled
-- when zero candidates exist.

insert into recalls (brand_id, recall_date, classification, reason, status, source, openfda_ref)
select b.id, v.recall_date::date, v.classification, v.reason, 'closed'::record_status,
       'openfda_food_enforcement', v.openfda_ref
from brands b, (values
    ('2013-06-07', 'Class I', 'Chocolate-coating cross-contamination: raw material supplier of the chocolate used for the bar coating had milk ingredients added inadvertently. One report of allergic reaction. (vega one nutrition bar, chocolate cherry)', 'F-1546-2013'),
    ('2013-06-07', 'Class I', 'Chocolate-coating cross-contamination: raw material supplier of the chocolate used for the bar coating had milk ingredients added inadvertently. One report of allergic reaction. (vega one nutrition bar, double chocolate)', 'F-1547-2013'),
    ('2013-06-07', 'Class I', 'Chocolate-coating cross-contamination: raw material supplier of the chocolate used for the bar coating had milk ingredients added inadvertently. One report of allergic reaction. (vega sport protein bar, chocolate coconut)', 'F-1548-2013'),
    ('2013-06-07', 'Class I', 'Chocolate-coating cross-contamination: raw material supplier of the chocolate used for the bar coating had milk ingredients added inadvertently. One report of allergic reaction. (vega sport protein bar, chocolate saviseed)', 'F-1549-2013'),
    ('2013-06-07', 'Class I', 'Chocolate-coating cross-contamination: raw material supplier of the chocolate used for the bar coating had milk ingredients added inadvertently. One report of allergic reaction. (vega one nutrition bar, chocolate almond)', 'F-1545-2013'),
    ('2013-11-08', 'Class II', 'Trace chloramphenicol (an antibiotic) from a third-party enzyme supplier. (Vega ONE Nutritional Shake, Vanilla Chai)', 'F-1143-2014'),
    ('2013-11-08', 'Class II', 'Trace chloramphenicol (an antibiotic) from a third-party enzyme supplier. (Vega ONE Nutritional Shake, Chocolate)', 'F-1146-2014'),
    ('2013-11-08', 'Class II', 'Trace chloramphenicol (an antibiotic) from a third-party enzyme supplier. (Vega ONE Nutritional Shake, French Vanilla -- the exact seeded flavor, 827g size among the affected lots)', 'F-1145-2014'),
    ('2013-11-08', 'Class II', 'Trace chloramphenicol (an antibiotic) from a third-party enzyme supplier. (Vega ONE Nutritional Shake, Natural)', 'F-1144-2014'),
    ('2013-11-08', 'Class II', 'Trace chloramphenicol (an antibiotic) from a third-party enzyme supplier. (Vega All-In-One Nutritional Shake, Berry)', 'F-1147-2014'),
    ('2013-11-08', 'Class II', 'Trace chloramphenicol (an antibiotic) from a third-party enzyme supplier. (Vega One Starter Kit)', 'F-1142-2014'),
    ('2013-11-08', 'Class II', 'Trace chloramphenicol (an antibiotic) from a third-party enzyme supplier. (Vega Sport Performance Protein, Chocolate Powder)', 'F-1140-2014'),
    ('2013-11-08', 'Class II', 'Trace chloramphenicol (an antibiotic) from a third-party enzyme supplier. (Vega Sport Performance Protein, Vanilla Powder)', 'F-1141-2014')
) as v(recall_date, classification, reason, openfda_ref)
where b.name = 'Vega';

insert into adverse_event_counts (brand_id, report_count, data_period, source)
select b.id, 45, 'cumulative through 2026-08-03', 'openfda_hfcs'
from brands b where b.name = 'Vega';

-- ----------------------------------------------------------------------------
-- Certifications (label + web research, retrieved 2026-08-03) --
-- claimed_unverified pending manual lookup at each certifier's own site, per
-- the worksheet's rule. Two distinct real certifying bodies confirmed, both
-- visible as seals on the label: Non-GMO Project (a third-party non-profit)
-- and Vegan Action/Vegan.org (issues the "Certified Vegan" mark). Neither
-- certification_type enum value fits either program specifically, so both
-- use 'other', distinguished by source -- same limitation already noted for
-- New Chapter's certifications.
-- ----------------------------------------------------------------------------
insert into certifications (product_id, cert_type, status, source, last_verified)
select p.id, 'other'::certification_type, 'claimed_unverified', 'label_claim_non_gmo_project_verified', now()
from products p where p.name = 'Vega One All-in-One Nutritional Shake, French Vanilla, 827g (Approx. 20 Servings)'
union all
select p.id, 'other'::certification_type, 'claimed_unverified', 'label_claim_vegan_certified_vegan_action', now()
from products p where p.name = 'Vega One All-in-One Nutritional Shake, French Vanilla, 827g (Approx. 20 Servings)';
