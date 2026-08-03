-- ============================================================================
-- PROVENIX — Seed SKU: Host Defense Mushrooms Grateful Dead Gummies —
-- Stay Mellow, Cherry Zen, 90 Gummies
--
-- 30-SKU push, candidate #7. Functional-mushroom + adaptogen gummy, a
-- licensed Grateful Dead collaboration. Legal entity: Fungi Perfecti, LLC
-- (dba Host Defense Mushrooms), founded 1980 by Paul Stamets (mycologist;
-- founder, owner, and Chief Science Officer), Shelton/Olympia, WA
-- (fungi.com "About Us"/"Who We Are", retrieved 2026-08-03).
--
-- Attribution: label (photographed directly by Aaron, retrieved
-- 2026-08-03) doesn't carry a distributor/manufacturer address in the
-- photographed panels. FDA Data Dashboard (inspections_classifications,
-- LegalName="Fungi Perfecti", retrieved 2026-08-03) resolves to exactly
-- one facility -- FEI 1000292840, Shelton, WA -- matching the recalling-
-- firm address on this brand's only openFDA recall (50 SE Nelson Rd,
-- Shelton, WA). 2 unique inspections (2019, 2023 -- each appears twice in
-- the raw API response, a known openFDA duplication pattern for multi-
-- product-code visits, not a Provenix data-entry issue), both NAI.
--
-- Recalls: 1 found (openFDA food/enforcement.json, retrieved 2026-08-03) --
-- Class II, 2019, undeclared wheat in "Host Defense MycoBotanicals Blood
-- Sugar" (a capsule product, different from the seeded gummy), 11,042
-- bottles, terminated 2019-06-28. Checked both "Fungi Perfecti" and "Host
-- Defense" as recalling_firm, and the drug/enforcement.json endpoint --
-- no other hits.
--
-- Adverse events (openFDA CAERS, retrieved 2026-08-03): 11 SUSPECT-role
-- reports under "Host Defense." Small brand, low count; spot-checked --
-- mostly "Vit/Min/Prot" industry code, one "Vegetables/Vegetable
-- Products" hit plausible for a mushroom product rather than a name
-- collision (not chased further given how distinctive "Host Defense" is
-- as a search term, unlike "Vega" or "AG1").
--
-- IMPORTANT CONTEXT NOT CAPTURED IN ANY SCORED FIELD -- this schema has no
-- table for "independent lab found a marketing-claim discrepancy" or
-- "industry labeling controversy," so it's documented here instead of
-- silently dropped:
--   1. Mycelium-vs-fruiting-body dispute: Host Defense's mushroom products
--      (including this gummy's Lion's Mane and Reishi actives) are grown
--      as "mycelium on grain," not fruiting bodies. Critics argue grain-
--      grown mycelium is low in beta-glucans and mostly starch filler;
--      Stamets and Fungi Perfecti (with 3 other companies) published a
--      2023 open letter defending "mushroom mycelium" as an accurate,
--      legitimate term. This is a live, unresolved industry science/
--      labeling dispute, not a settled compliance fact either direction.
--   2. ConsumerLab testing (cited via Lexology, ingredientslabel.com
--      coverage, retrieved 2026-08-03) found Host Defense Reishi
--      (capsule line, not this gummy) claimed 550 mg "polysaccharides"
--      per serving of which only 5.6 mg was actual beta-glucan --
--      potentially misleading given polysaccharide claims are commonly
--      read as a beta-glucan proxy. Specific to the Reishi capsule
--      product, not independently verified against this gummy SKU's
--      actual Lion's Mane/Reishi content.
--   3. Separately, and NOT a mark against the brand: Fungi Perfecti
--      itself publicly reported (PR Newswire, April 2023) discovering
--      counterfeit Host Defense products with undeclared gluten/allergens
--      being sold on eBay and Walmart.com by third parties impersonating
--      the brand -- proactive brand-protection, not their own recall.
-- Flagging to Aaron: is a new schema category worth adding for #1/#2-style
-- findings (independent lab or scientific disputes short of an FDA
-- action), or is comment-only documentation sufficient for now?
--
-- Ingredient list: fully quantified, no proprietary blend -- every active
-- (Lion's Mane 375mg, Reishi 375mg, Ashwagandha 100mg, Chamomile 100mg)
-- has an individual disclosed dose.
--
-- Certifications: label shows USDA Organic and Non-GMO Project Verified
-- (real, verifiable quality/sourcing certs, both entered as 'other' per
-- the enum limitation already noted for New Chapter/Vega). Also shows
-- Vegan and Gluten-Free marks (self-declared claims, no certifying body
-- named on-label) and Certified B Corporation (corporate social-
-- responsibility cert, not a product-quality certification this schema
-- tracks -- same exclusion reasoning as New Chapter's B Corp mention).
--
-- No ndi_flags row: Lion's Mane, Reishi, Ashwagandha, and Chamomile are
-- all long-established, non-novel ingredients.
-- ============================================================================

with brand_host_defense as (
    insert into brands (name, address, website)
    values (
        'Host Defense Mushrooms',
        'Fungi Perfecti, LLC, Shelton/Olympia, WA, USA (founded 1980 by Paul Stamets, mycologist and '
        || 'Chief Science Officer)',
        'www.hostdefense.com'
    )
    returning id
),
product_grateful_dead as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        id,
        'Host Defense Mushrooms Grateful Dead Gummies — Stay Mellow, Cherry Zen, 90 Gummies',
        'supplement_gmp',
        '{
            "servingSize": "3 Gummies",
            "servingsPerContainer": 30,
            "activeIngredients": [
                {"name": "Lion''s Mane (Hericium erinaceus) mycelium/fermented brown rice biomass", "amountPerServing": "375 mg", "percentDV": null},
                {"name": "Reishi (Ganoderma lucidum s.l.) mycelium/fermented brown rice biomass", "amountPerServing": "375 mg", "percentDV": null},
                {"name": "Ashwagandha (Withania somnifera) root extract", "amountPerServing": "100 mg", "percentDV": null},
                {"name": "Chamomile (Matricaria chamomilla) flower extract", "amountPerServing": "100 mg", "percentDV": null}
            ],
            "otherIngredients": [
                "Tapioca Syrup", "Cane Sugar", "Water", "Vegetable Glycerin", "Pectin",
                "Citric Acid", "Sodium Citrate", "Natural Flavors", "Vegetable Juice (color)",
                "Sunflower Oil", "Carnauba Wax", "Monk Fruit Extract"
            ]
        }'::jsonb,
        true
    from brand_host_defense
    returning id
),
facility_shelton as (
    insert into facilities (name, address, country, fei_number)
    values (
        'Fungi Perfecti, LLC — Shelton facility',
        '50 SE Nelson Rd, Shelton, WA 98584, USA',
        'US',
        '1000292840'
    )
    returning id
),
attribution_host_defense as (
    insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
    select
        id,
        'high'::attribution_confidence,
        'user_photo'::attribution_source,
        'FDA Data Dashboard (inspections_classifications, LegalName="Fungi Perfecti", retrieved '
        || '2026-08-03) resolves to exactly one facility -- FEI 1000292840, Shelton, WA. Confirmed '
        || 'against this brand''s own openFDA recall (F-1231-2019), which lists the same address '
        || '(50 SE Nelson Rd, Shelton, WA) as the recalling firm''s facility. 2 unique inspections '
        || '(2019, 2023), both NAI.',
        'Single unambiguous FDA-registered facility, cross-confirmed by matching address on this '
        || 'brand''s own recall record rather than label text alone (the photographed panels didn''t '
        || 'carry distributor/manufacturer address text).'
    from product_grateful_dead
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select attribution_host_defense.id, facility_shelton.id, true
from attribution_host_defense, facility_shelton;

-- ----------------------------------------------------------------------------
-- Inspection history (FDA Data Dashboard, FEI 1000292840, retrieved 2026-08-03)
-- ----------------------------------------------------------------------------
insert into inspection_classifications (facility_id, classification, inspection_end_date, source, retrieved_at)
select f.id, v.classification::inspection_classification, v.inspection_end_date::date,
       'fda_data_dashboard_inspections_classifications', now()
from facilities f,
     (values
        ('NAI', '2019-09-06'),
        ('NAI', '2023-06-16')
     ) as v(classification, inspection_end_date)
where f.fei_number = '1000292840';

-- ----------------------------------------------------------------------------
-- Recall (openFDA food/enforcement.json, retrieved 2026-08-03) — brand-
-- level, a different product (MycoBotanicals Blood Sugar capsules)
-- ----------------------------------------------------------------------------
insert into recalls (brand_id, recall_date, classification, reason, status, source, openfda_ref)
select b.id, '2019-02-28'::date, 'Class II',
       'Host Defense MycoBotanicals Blood Sugar, 60 ct. bottles, recalled due to undeclared wheat. '
       || '11,042 bottles affected, distributed US/Norway/Canada.',
       'closed'::record_status, 'openfda_food_enforcement', 'F-1231-2019'
from brands b where b.name = 'Host Defense Mushrooms';

-- ----------------------------------------------------------------------------
-- Adverse events (openFDA CAERS, retrieved 2026-08-03)
-- ----------------------------------------------------------------------------
insert into adverse_event_counts (brand_id, report_count, data_period, source)
select b.id, 11, 'cumulative through 2026-08-03', 'openfda_hfcs'
from brands b where b.name = 'Host Defense Mushrooms';

-- ----------------------------------------------------------------------------
-- Lab testing (web research, retrieved 2026-08-03)
-- ----------------------------------------------------------------------------
with p as (select id from products where name = 'Host Defense Mushrooms Grateful Dead Gummies — Stay Mellow, Cherry Zen, 90 Gummies')
insert into lab_testing (product_id, tier, evidence, source, last_verified)
select p.id, 'claimed_no_public_coa'::lab_testing_tier,
       'No public per-lot CoA lookup tool found. Note: independent ConsumerLab testing of Host '
       || 'Defense Reishi (capsule line, not this gummy) found a 550mg "polysaccharide" claim '
       || 'contained only 5.6mg actual beta-glucan -- a live industry dispute over mycelium-grown '
       || 'mushroom products'' bioactive content, not independently verified against this specific SKU.',
       'web_research', now()
from p;

-- ----------------------------------------------------------------------------
-- Certifications (label, retrieved 2026-08-03) — claimed_unverified pending
-- manual lookup at each certifier's own site
-- ----------------------------------------------------------------------------
with p as (select id from products where name = 'Host Defense Mushrooms Grateful Dead Gummies — Stay Mellow, Cherry Zen, 90 Gummies')
insert into certifications (product_id, cert_type, status, source, last_verified)
select p.id, 'other'::certification_type, 'claimed_unverified', 'label_claim_usda_organic', now()
from p
union all
select p.id, 'other'::certification_type, 'claimed_unverified', 'label_claim_non_gmo_project_verified', now()
from p;
