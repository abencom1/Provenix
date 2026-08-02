-- ============================================================================
-- PROVENIX — Backfill: Herbalife Kids Immune Health + Multivitamin Gummies
-- ingredient_list, replacing the "not yet confirmed" placeholder
--
-- Source: physical label, photographed directly by Aaron (retrieved
-- 2026-08-02) — Supplement Facts panel and front-of-bottle panel, LOT
-- H326408A00, BB 04/05/2027. This is what the automated research pass
-- (DSLD lookup, herbalife.com fetch) could not reach: the SKU isn't in
-- DSLD yet and the product page is JS-rendered.
--
-- No third-party certification found on the label either (confirms the
-- earlier web-research "none found" result): front panel carries only a
-- crossed-out "Fe" icon (iron-free — consistent with 0mg iron in the
-- panel, a formulation claim, not a cert) and a crossed-out wheat-stalk
-- icon (self-declared gluten-free, no certifying body named) plus a
-- "Sugar-Free" seal — none are third-party certification marks (no NSF/
-- USP/Non-GMO Project/Informed-Choice logo), so per the worksheet's own
-- rule (never trust a badge without a named certifier), no certifications
-- row is inserted.
--
-- Also surfaced, not acted on here: the label reads "Made in China" under
-- "Formulated and distributed exclusively by: HERBALIFE INTERNATIONAL OF
-- AMERICA, INC." — of the 4 SEC-10-K facilities currently linked
-- (Winston-Salem NC, Lake Forest CA, Changsha CN, Suzhou CN), only the 2
-- China-based ones are plausible for this specific SKU. Flagging for a
-- separate facility-linkage review rather than narrowing it here.
-- ============================================================================

update products
set ingredient_list = '{
    "servingSize": "2 gummies (4g)",
    "servingsPerContainer": 30,
    "activeIngredients": [
        {"name": "Vitamin A (as Retinyl Palmitate)", "amountPerServing": "180 mcg RAE", "percentDV": "20%"},
        {"name": "Vitamin C (as Ascorbic Acid)", "amountPerServing": "18 mg", "percentDV": "20%"},
        {"name": "Vitamin D (as Cholecalciferol)", "amountPerServing": "4 mcg", "percentDV": "20%"},
        {"name": "Vitamin E (as DL-Alpha-Tocopheryl Acetate)", "amountPerServing": "3 mg", "percentDV": "20%"},
        {"name": "Vitamin K (as Phytonadione)", "amountPerServing": "24 mcg", "percentDV": "20%"},
        {"name": "Niacin (as Niacinamide)", "amountPerServing": "3.2 mg", "percentDV": "20%"},
        {"name": "Vitamin B6 (as Pyridoxine Hydrochloride)", "amountPerServing": "0.34 mg", "percentDV": "20%"},
        {"name": "Folate (50 mcg folic acid)", "amountPerServing": "80 mcg DFE", "percentDV": "20%"},
        {"name": "Vitamin B12 (as Cyanocobalamin)", "amountPerServing": "0.48 mcg", "percentDV": "20%"},
        {"name": "Iodine (as Potassium Iodide)", "amountPerServing": "30 mcg", "percentDV": "20%"},
        {"name": "Zinc (as Zinc Citrate)", "amountPerServing": "2.2 mg", "percentDV": "20%"}
    ],
    "otherIngredients": [
        "Maltitol Syrup", "Erythritol", "Glycerin", "Pectin", "Citric Acid", "Sodium Citrate",
        "Natural Flavors", "Turmeric (Color)", "Vegetable Juice (Color)"
    ]
}'::jsonb
where name = 'Herbalife Kids Immune Health + Multivitamin Gummies, 60 ct (Herbalife SKU 542K)';
