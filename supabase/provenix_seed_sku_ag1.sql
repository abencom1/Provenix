-- ============================================================================
-- PROVENIX — Seed SKU: AG1 Daily Foundational Nutrition, 40 CT (40 x 12g
-- Stick Packs, 480g)
--
-- 30-SKU push, candidate #5 (massive proprietary-blend DTC brand, picked
-- specifically to test ingredient_transparency scoring against heavy
-- marketing claims -- "75 vitamins, minerals, probiotics, and whole food
-- sourced ingredients"). Legal entity: AG1 USA Inc. (formerly Athletic
-- Greens (USA) Inc., rebranded 2022 under President/COO-turned-CEO Kat
-- Cole), Carson City, NV. Privately held, VC-backed, not owned by a
-- larger parent (Wikipedia, Tracxn, retrieved 2026-08-03). Founder Chris
-- Ashenden resigned in 2024 after pre-AG1 legal issues became public --
-- a governance/reputation fact, not a compliance record this schema
-- tracks, so not entered as a row anywhere.
--
-- Attribution: label (photographed directly by Aaron, retrieved
-- 2026-08-03) reads "Distributed by: AG1 USA Inc. | Carson City, NV,
-- 89701" -- distributor-typed, no manufacturer named. FDA Data Dashboard
-- (inspections_classifications, retrieved 2026-08-03) resolves
-- LegalName="Athletic Greens" to exactly one facility -- FEI 3010143279,
-- "Athletic Greens (Usa) Inc," Carson City, NV -- matching the label's
-- city/state exactly (same entity, pre-rebrand legal name still on FDA's
-- registry). 1 inspection, NAI, no VAI/OAI. "AG1" and "AG1 USA" as exact
-- legal names return zero results -- the pre-rebrand name is what's
-- actually registered.
--
-- Recalls: none found. Checked recalling_firm:"Athletic Greens" and "AG1"
-- against both food/enforcement.json and drug/enforcement.json (all four
-- combinations NOT_FOUND, retrieved 2026-08-03). Also checked for a
-- California Prop 65 60-day notice specific to this brand -- AG1 carries
-- a general Prop 65 lead warning (common across greens-powder products
-- from trace botanical heavy-metal uptake) and faces a private class-
-- action lawsuit over lead content, but neither is a government
-- regulatory action: the lawsuit is civil litigation (same treatment as
-- the Align/Cellucor advertising suits -- not entered), and no specific
-- dated 60-day notice against this brand was found in any source checked
-- (unlike the confirmed, dated Optimum Nutrition Prop 65 notices).
--
-- Adverse events (openFDA CAERS, retrieved 2026-08-03): searched under
-- both the pre- and post-rebrand brand names since CAERS reports use
-- whichever name was printed on the product at the time --
-- products.name_brand:"Athletic Greens" AND role:"SUSPECT" = 19 reports;
-- products.name_brand:"AG1" AND role:"SUSPECT" = 241 reports. Both spot-
-- checked (10 of 10 samples each) before trusting the much larger AG1
-- count given how short/generic that string is -- all genuine matches
-- ("AG1 Whole Food Pouch," "AG1 Next Gen Formula," etc.), no collision
-- with an unrelated product. Combined total 260 -- the two name-windows
-- shouldn't overlap since a given report uses one printed name or the
-- other, not both.
--
-- Testing: AG1's own site and independent comparisons (retrieved
-- 2026-08-03) confirm batch testing for heavy metals/microbials/banned
-- substances against USP and NSF limits, but explicitly no public per-lot
-- CoA lookup -- named as a transparency gap relative to Thorne, Momentous,
-- and Ritual specifically. claimed_no_public_coa.
--
-- Certifications: NSF Certified for Sport badge is directly visible on
-- the physical label (front panel and side panel both photographed).
-- Web research also surfaced an Informed-Choice database listing for this
-- brand, but since that program isn't shown anywhere on this specific
-- product's label, it's deliberately not added here -- entering only
-- what's directly evidenced on the actual product, not a claim sourced
-- secondhand. claimed_unverified pending manual lookup at NSF's own site.
--
-- Ingredient list: base vitamins/minerals are individually quantified on
-- the Supplement Facts panel. The label's "75 ingredients" marketing
-- claim is delivered via 4 named, gram-totaled proprietary blends with NO
-- individual component amounts disclosed -- modeled as actual
-- proprietaryBlends entries here (unlike Vega's implicit, unnamed
-- opacity, AG1 explicitly names and totals each blend, a cleaner match to
-- this schema's proprietaryBlends type). Two supplement facts photos were
-- taken; the first (blurrier) pass produced a transcription error --
-- Zinc and Selenium's amounts were swapped (physiologically implausible:
-- 15mg selenium would be a toxic megadose) -- caught by cross-checking
-- amount against %DV math before entry, then corrected against a second,
-- clearer photo. All values below are from that clearer photo.
-- ============================================================================

with brand_ag1 as (
    insert into brands (name, address, website)
    values (
        'AG1',
        'AG1 USA Inc. (formerly Athletic Greens (USA) Inc.), Carson City, NV 89701, USA',
        'www.drinkag1.com'
    )
    returning id
),
product_ag1 as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        id,
        'AG1 Daily Foundational Nutrition, 40 CT (40 x 12g Stick Packs, 480g)',
        'supplement_gmp',
        '{
            "servingSize": "One Stick Pack (12g)",
            "servingsPerContainer": 40,
            "activeIngredients": [
                {"name": "Protein", "amountPerServing": "2 g", "percentDV": null},
                {"name": "Dietary Fiber", "amountPerServing": "2 g", "percentDV": "7%"},
                {"name": "Vitamin A (as beta-carotene)", "amountPerServing": "550 mcg RAE", "percentDV": "61%"},
                {"name": "Vitamin C (as ascorbic acid)", "amountPerServing": "420 mg", "percentDV": "467%"},
                {"name": "Vitamin E (as d-alpha tocopherol succinate)", "amountPerServing": "83 mg", "percentDV": "553%"},
                {"name": "Thiamin (Vitamin B1) (as thiamine hydrochloride)", "amountPerServing": "3 mg", "percentDV": "250%"},
                {"name": "Riboflavin (Vitamin B2)", "amountPerServing": "2 mg", "percentDV": "154%"},
                {"name": "Niacin (as nicotinic acid, niacinamide)", "amountPerServing": "20 mg NE", "percentDV": "125%"},
                {"name": "Vitamin B6 (as pyridoxine hydrochloride)", "amountPerServing": "3 mg", "percentDV": "176%"},
                {"name": "Folate (as 5-MTHF)", "amountPerServing": "680 mcg DFE", "percentDV": "170%"},
                {"name": "Vitamin B12 (as methylcobalamin)", "amountPerServing": "22 mcg", "percentDV": "917%"},
                {"name": "Biotin (Vitamin B7)", "amountPerServing": "330 mcg", "percentDV": "1100%"},
                {"name": "Pantothenic acid (as calcium pantothenate)", "amountPerServing": "4 mg", "percentDV": "80%"},
                {"name": "Calcium (as calcium citrate, calcium carbonate, calcium phosphate)", "amountPerServing": "118 mg", "percentDV": "9%"},
                {"name": "Iron", "amountPerServing": "1 mg", "percentDV": "6%"},
                {"name": "Phosphorus (as potassium phosphate, calcium phosphate)", "amountPerServing": "130 mg", "percentDV": "10%"},
                {"name": "Magnesium (as magnesium glycinate)", "amountPerServing": "26 mg", "percentDV": "6%"},
                {"name": "Zinc (as zinc citrate)", "amountPerServing": "15 mg", "percentDV": "136%"},
                {"name": "Selenium (as selenomethionine)", "amountPerServing": "20 mcg", "percentDV": "36%"},
                {"name": "Copper (as copper gluconate)", "amountPerServing": "0.2 mg", "percentDV": "22%"},
                {"name": "Manganese (as manganese amino acid chelate)", "amountPerServing": "0.4 mg", "percentDV": "17%"},
                {"name": "Chromium (as chromium picolinate)", "amountPerServing": "25 mcg", "percentDV": "71%"},
                {"name": "Sodium", "amountPerServing": "45 mg", "percentDV": "2%"},
                {"name": "Potassium", "amountPerServing": "250 mg", "percentDV": "5%"}
            ],
            "proprietaryBlends": [
                {
                    "name": "Alkaline, Nutrient-Dense Raw Superfood Complex",
                    "components": [
                        "Organic spirulina", "lecithin (>65% phospholipids)", "organic apple powder",
                        "inulin (FOS prebiotics)", "organic chlorella powder", "organic wheat grass powder (leaf)",
                        "organic alfalfa powder (leaf)", "organic barley (Hordeum vulgare) leaf powder",
                        "broccoli powder", "papaya (Carica papaya) fruit powder", "beet root powder",
                        "carrot powder", "acerola fruit extract (4:1)", "ginger rhizome powder",
                        "cocoa bean powder", "licorice root powder", "spinach leaf powder",
                        "rose hip (Rosa canina) fruit powder (4:1)", "pineapple fruit powder",
                        "slippery elm (Ulmus rubra) bark powder", "lycium berry fruit extract (4:1)",
                        "kelp whole plant powder", "green tea (Camellia sinensis) extract leaf (10:1)",
                        "bilberry fruit extract (100:1)", "grape seed extract (120:1, std. 95% OPC)"
                    ],
                    "note": "7.3 g total, no individual component amounts disclosed"
                },
                {
                    "name": "Nutrient-Dense Extracts, Herbs & Antioxidants",
                    "components": [
                        "Alkaline pea protein isolate", "citrus bioflavonoids extract", "R,S alpha-lipoic acid",
                        "artichoke leaf extract (15:1)", "coenzyme Q10 (ubidecarenone)",
                        "rhodiola (Rhodiola rosea) root dry extract (15:1)", "rosemary leaf extract (4:1)",
                        "ashwagandha (Withania somnifera) root extract (5:1)", "beta glucans",
                        "dandelion whole plant dry concentrate (4:1)",
                        "eleuthero (Eleutherococcus senticosus) root extract (10:1)", "policosanol",
                        "hawthorn berry extract (10:1)", "milk thistle seed extract (70:1)",
                        "Vitamin K2 (as menaquinone-7)"
                    ],
                    "note": "2.1 g total, no individual component amounts disclosed"
                },
                {
                    "name": "Digestive Enzyme & Super Mushroom Complex",
                    "components": [
                        "Bromelain (dietary enzyme)", "reishi mushroom powder", "shiitake mushroom powder",
                        "Astragalus (Astragalus membranaceus) root extract (4:1)", "burdock root extract (4:1)"
                    ],
                    "note": "154 mg total, no individual component amounts disclosed"
                },
                {
                    "name": "Dairy-Free Probiotics",
                    "components": [
                        "Lactobacillus acidophilus - UALa-01", "Bifidobacterium bifidum - UABb-10"
                    ],
                    "note": "7.2 billion CFU / 54 mg total, no individual strain-level CFU split disclosed"
                }
            ],
            "otherIngredients": ["Natural flavors", "citric acid", "stevia (Stevia rebaudiana) leaf extract", "silica"]
        }'::jsonb,
        true
    from brand_ag1
    returning id
),
facility_ag1 as (
    insert into facilities (name, address, country, fei_number)
    values (
        'Athletic Greens (Usa) Inc — Carson City facility',
        'Carson City, NV, USA',
        'US',
        '3010143279'
    )
    returning id
),
attribution_ag1 as (
    insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
    select
        id,
        'high'::attribution_confidence,
        'user_photo'::attribution_source,
        'Label (photographed directly by Aaron, retrieved 2026-08-03): "Distributed by: AG1 USA Inc. '
        || '| Carson City, NV, 89701." FDA Data Dashboard (inspections_classifications, '
        || 'LegalName="Athletic Greens", retrieved 2026-08-03) resolves to exactly one facility -- FEI '
        || '3010143279, "Athletic Greens (Usa) Inc," Carson City, NV -- matching the label''s city/'
        || 'state exactly under the company''s pre-rebrand legal name. 1 inspection, NAI, no VAI/OAI. '
        || '"AG1" and "AG1 USA" as exact legal names both return zero results.',
        'Single unambiguous FDA-registered facility at the label''s city/state, found under the '
        || 'company''s pre-2022-rebrand legal name still on file with FDA -- same reasoning pattern as '
        || 'New Chapter and Nature''s Way: distributor-typed label language doesn''t block high '
        || 'confidence when the FDA registry match is this specific.'
    from product_ag1
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select attribution_ag1.id, facility_ag1.id, true
from attribution_ag1, facility_ag1;

insert into adverse_event_counts (brand_id, report_count, data_period, source)
select b.id, 260, 'cumulative through 2026-08-03 (19 under "Athletic Greens" + 241 under "AG1", both name-eras spot-checked for genuine matches)', 'openfda_hfcs'
from brands b where b.name = 'AG1';

with p as (select id from products where name = 'AG1 Daily Foundational Nutrition, 40 CT (40 x 12g Stick Packs, 480g)')
insert into lab_testing (product_id, tier, evidence, source, last_verified)
select p.id, 'claimed_no_public_coa'::lab_testing_tier,
       'AG1 tests each batch for heavy metals, microbials, allergens, and banned substances against '
       || 'USP/NSF limits, per its own site and independent comparisons -- but no public per-lot CoA '
       || 'lookup tool exists, explicitly named as a gap relative to Thorne, Momentous, and Ritual.',
       'web_research', now()
from p;

with p as (select id from products where name = 'AG1 Daily Foundational Nutrition, 40 CT (40 x 12g Stick Packs, 480g)')
insert into certifications (product_id, cert_type, status, source, last_verified)
select p.id, 'nsf_certified_for_sport'::certification_type, 'claimed_unverified', 'label_photo_nsf_certified_for_sport', now()
from p;
