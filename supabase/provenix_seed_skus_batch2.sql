-- ============================================================================
-- PROVENIX — Seed SKU batch 2: the remaining 9 worksheet SKUs (#2, #3, #4,
-- #5, #6, #8, #9, #11, #12), completing all 12.
--
-- Same scope as batch 1: only brands, facilities, products,
-- manufacturer_attributions, manufacturer_attribution_facilities. No
-- recalls/adverse events pulled yet for these 8 new brands (only the
-- original 4 have that data) — a natural follow-up, not assumed in scope
-- here. Full sourcing for every field is in provenix_seed_sku_findings.md,
-- retrieved 2026-07-22/23.
--
-- Per the facility-rollup standard: every candidate facility found gets
-- linked, not just the best guess. Run once, after batch1 + batch1b +
-- migration 001 + the Garden of Life backfill.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- #2 — NOW Foods Magnesium Citrate (high confidence, single facility)
-- ----------------------------------------------------------------------------
with brand_now as (
    insert into brands (name, address, website)
    values ('NOW Foods', '395 S. Glen Ellyn Rd., Bloomingdale, IL 60108, USA', 'www.nowfoods.com')
    returning id
),
facility_now as (
    insert into facilities (name, address, country, fei_number)
    values ('NOW Health Group Inc.', '395 Glen Ellyn Rd, Bloomingdale, IL 60108', 'US', '1482865')
    returning id
),
product_2 as (
    insert into products (brand_id, name, regulatory_pathway, is_seed_sku)
    select brand_now.id, 'NOW Foods Magnesium Citrate (UPC 7 33739 01294 4)', 'supplement_gmp', true
    from brand_now
    returning id
),
attribution_2 as (
    insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
    select product_2.id, 'high', 'user_photo',
        'DSLD label record (id 313576, dsldapi.od.nih.gov, retrieved 2026-07-23) contact type is '
        || 'directly "Manufactured by": NOW FOODS, 395 S. Glen Ellyn Rd., Bloomingdale, IL 60108. '
        || 'FDA Data Dashboard (inspections_classifications, LegalName=NOW Foods/NOW Health Group) '
        || 'confirms FEI 1482865 at the same address exactly (17 inspections 2009-2025, mostly '
        || 'NAI, some VAI, none OAI).',
        'Direct manufacturer-typed label statement matching a single unambiguous FDA-registered '
        || 'facility exactly.'
    from product_2
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select attribution_2.id, facility_now.id, true
from attribution_2, facility_now;

-- ----------------------------------------------------------------------------
-- #3 — Thorne Vitamin D (liquid drops) — reuses Thorne's existing brand/facility
-- ----------------------------------------------------------------------------
with existing_thorne_brand as (
    select id from brands where name = 'Thorne'
),
existing_thorne_facility as (
    select id from facilities where fei_number = '3014491710'
),
product_3 as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select existing_thorne_brand.id, 'Thorne Vitamin D (liquid drops, UPC 6 93749 16801 0)',
        'supplement_gmp',
        '{
            "servingSize": "2 Drops",
            "activeIngredients": [
                {"name": "Vitamin D", "amountPerServing": "25 mcg", "percentDV": 125}
            ],
            "otherIngredients": []
        }'::jsonb,
        true
    from existing_thorne_brand
    returning id
)
insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
select product_3.id, 'high', 'user_photo',
    'DSLD label record (id 298102, retrieved 2026-07-23) reads "Manufactured in the USA... for '
    || 'Thorne Research, Inc." (Distributor-typed, no address given) — thinner evidence than the '
    || 'Ashwagandha label (#10), but Thorne is a single vertically-integrated manufacturer already '
    || 'confirmed via direct label photo there. Reuses that same facility (FEI 3014491710, '
    || 'Summerville SC) by brand consistency. Note: this SKU shows no NSF Certified for Sport '
    || 'claim in its DSLD data, so it does not exercise the cert-lookup path the worksheet wanted '
    || 'tested for #3.',
    'Same manufacturer as an already-confirmed Thorne product; reused rather than re-proven per-SKU.'
from product_3;

with attribution_3 as (
    select ma.id as attribution_id
    from manufacturer_attributions ma
    join products p on p.id = ma.product_id
    where p.name = 'Thorne Vitamin D (liquid drops, UPC 6 93749 16801 0)' and ma.is_current
),
existing_thorne_facility as (
    select id from facilities where fei_number = '3014491710'
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select attribution_3.attribution_id, existing_thorne_facility.id, true
from attribution_3, existing_thorne_facility;

-- ----------------------------------------------------------------------------
-- #4 — Optimum Nutrition Gold Standard 100% Whey (high confidence, single facility)
-- ----------------------------------------------------------------------------
with brand_on as (
    insert into brands (name, address, website)
    values ('Optimum Nutrition', '3500 Lacey Road, Suite 1200, Downers Grove, IL 60515, USA', 'www.optimumnutrition.com')
    returning id
),
facility_on as (
    insert into facilities (name, address, country, fei_number)
    values ('Glanbia Performance Nutrition Manufacturing Inc', '3500 Lacey Rd Ste 1200, Downers Grove, IL', 'US', '3016573922')
    returning id
),
product_4 as (
    insert into products (brand_id, name, regulatory_pathway, is_seed_sku)
    select brand_on.id, 'Optimum Nutrition Gold Standard 100% Whey, Double Rich Chocolate (UPC 7 48927 05226 8)', 'supplement_gmp', true
    from brand_on
    returning id
),
attribution_4 as (
    insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
    select product_4.id, 'high', 'user_photo',
        'DSLD label record (id 308405, retrieved 2026-07-23) contact type "Manufactured by": '
        || 'Optimum Nutrition, 3500 Lacey Road, Suite 1200, Downers Grove, IL 60515. FDA Data '
        || 'Dashboard (LegalName=Optimum Nutrition/Glanbia Performance Nutrition) returns 7 '
        || 'distinct facilities; FEI 3016573922, "Glanbia Performance Nutrition Manufacturing '
        || 'Inc," has MANUFACTURING explicitly in its legal name and matches the label address '
        || 'exactly. The other 6 (Sunrise FL, Walterboro SC, 2x Aurora IL, Middlesbrough UK, and '
        || 'an Aurora IL Distribution Center) are differentiable by name/address/function and '
        || 'excluded as non-candidates.',
        'Direct manufacturer-typed label statement matching a single facility whose own legal '
        || 'name confirms its manufacturing role.'
    from product_4
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select attribution_4.id, facility_on.id, true
from attribution_4, facility_on;

-- ----------------------------------------------------------------------------
-- #5 — Nordic Naturals Ultimate Omega (moderate, 2 candidates, 1 primary)
-- ----------------------------------------------------------------------------
with brand_nn as (
    insert into brands (name, address, website)
    values ('Nordic Naturals', 'Nordic Naturals Mfg, Inc., 111 Jennings Drive, Watsonville, CA 95076, USA', 'www.nordic.com')
    returning id
),
nn_facilities (name, address, fei_number, is_primary) as (
    values
        ('Nordic Naturals, Inc.', '111 Jennings Way, Watsonville, CA', '3008880179', true),
        ('Nordic Naturals Manufacturing', '2390 Oak Ridge Way, Vista, CA', '3003710288', false)
),
inserted_nn_facilities as (
    insert into facilities (name, address, country, fei_number)
    select name, address, 'US', fei_number from nn_facilities
    returning id, fei_number
),
product_5 as (
    insert into products (brand_id, name, regulatory_pathway, is_seed_sku)
    select brand_nn.id, 'Nordic Naturals Ultimate Omega, Lemon', 'supplement_gmp', true
    from brand_nn
    returning id
),
attribution_5 as (
    insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
    select product_5.id, 'moderate', 'inferred',
        'DSLD label record (id 313197, retrieved 2026-07-23) reads "Manufactured in the U.S. by": '
        || 'Nordic Naturals Mfg, Inc., 111 Jennings Drive, Watsonville, CA 95076. FDA Data '
        || 'Dashboard shows FEI 3008880179 at "111 Jennings Way," same house number/city/state '
        || '(only the street suffix differs, same pattern as Garden of Life''s naming variance) — '
        || 'the best-evidenced match. A second real site, FEI 3003710288 "Nordic Naturals '
        || 'Manufacturing," 2390 Oak Ridge Way, Vista CA, is a genuinely different location also '
        || 'named Manufacturing and cannot be ruled out for this SKU.',
        'Address match with a minor suffix discrepancy, plus a second plausible manufacturing '
        || 'site under the same company — linked per the facility-rollup standard.'
    from product_5
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select attribution_5.id, inserted_nn_facilities.id, inserted_nn_facilities.fei_number = '3008880179'
from attribution_5, inserted_nn_facilities;

-- ----------------------------------------------------------------------------
-- #6 — Ritual Essential for Women (unresolved facility; strong ingredient-transparency signal)
-- ----------------------------------------------------------------------------
with brand_ritual as (
    insert into brands (name, website)
    values ('Ritual', 'www.ritual.com')
    returning id
),
product_6 as (
    insert into products (brand_id, name, regulatory_pathway, is_seed_sku)
    select brand_ritual.id, 'Ritual Essential for Women, Mint Essenced', 'supplement_gmp', true
    from brand_ritual
    returning id
)
insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
select product_6.id, null, null,
    'No FDA facility found under "Ritual" in any name variant (retrieved 2026-07-23) — the only '
    || 'matches were unrelated companies (a chocolate maker, an energy-drink company). DSLD''s own '
    || 'manufacturer-typed contact (id 278454) has no name or address populated at all. Ritual''s '
    || 'own site discloses ingredient-level supplier traceability instead ("Made Traceable(R)") — '
    || 'e.g. Vitamin D3 from The GHT Companies (Nottingham, UK), Omega-3 DHA from Algarithm '
    || 'Ingredients Inc. (Saskatoon, Canada) — real ingredient_transparency data that does not '
    || 'identify who does final encapsulation/bottling.',
    'Zero candidate facilities to link. A real example of high ingredient-level transparency '
    || 'coexisting with unresolved manufacturer attribution.'
from product_6;

-- ----------------------------------------------------------------------------
-- #8 — Nature''s Bounty Fish Oil (moderate, 8 candidates, none primary)
-- ----------------------------------------------------------------------------
with brand_nb as (
    insert into brands (name, address, website)
    values ('Nature''s Bounty', 'Nature''s Bounty, Inc., Bohemia, NY, USA', 'www.NaturesBounty.com')
    returning id
),
nb_facilities (name, address, fei_number) as (
    values
        ('NBTY, Inc.', '1 Nutrition Plz, Carbondale, IL', '1417820'),
        ('NBTY Acquisition LLC', '7366 Orangewood Ave, Garden Grove, CA', '2016480'),
        ('Nutro Laboratories, a div of NBTY, Inc.', '650 Hadley Rd, S Plainfield, NJ', '2243796'),
        ('NBTY Acquisition LLC', '901 E 233rd St, Carson, CA', '1000150275'),
        ('NBTY Manufacturing Florida, Inc.', '4365 Arnold Ave, Naples, FL', '3003476113'),
        ('NBTY, Inc. dba Leiner Health Products', '27655b Avenue Hopkins, Valencia, CA', '3004893365'),
        ('NBTY Acquisition LLC', '20642 S Fordyce Ave, Carson, CA', '3006349821'),
        ('The Nature''s Bounty Co.', '3001 Center Port Cir, Pompano Beach, FL', '3008682142')
),
inserted_nb_facilities as (
    insert into facilities (name, address, country, fei_number)
    select name, address, 'US', fei_number from nb_facilities
    returning id
),
product_8 as (
    insert into products (brand_id, name, regulatory_pathway, is_seed_sku)
    select brand_nb.id, 'Nature''s Bounty Fish Oil 1200 mg (UPC 0 74312 16887 1)', 'supplement_gmp', true
    from brand_nb
    returning id
),
attribution_8 as (
    insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
    select product_8.id, 'moderate', 'inferred',
        'DSLD label record (id 240786, retrieved 2026-07-23): "Carefully Manufactured for" '
        || '(Distributor-typed), Nature''s Bounty, Inc., Bohemia, NY — no street address. FDA Data '
        || 'Dashboard (LegalName=Nature''s Bounty/NBTY) returns 8 distinct facilities across IL, '
        || 'CA, NJ, FL under the NBTY corporate family, including one explicitly named "The '
        || 'Nature''s Bounty Co." (Pompano Beach FL) — company-level confirmation similar to '
        || 'Pharmavite''s "dba Nature Made." None match Bohemia, NY directly.',
        'Company-level manufacturer identity is well evidenced via the NBTY corporate family, but '
        || 'no single facility narrows down; all 8 linked as candidates per the rollup standard.'
    from product_8
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select attribution_8.id, inserted_nb_facilities.id, false
from attribution_8, inserted_nb_facilities;

-- ----------------------------------------------------------------------------
-- #9 — Kirkland Signature Extra Strength Vitamin D3 2000 IU (unresolved)
-- ----------------------------------------------------------------------------
with brand_kirkland as (
    insert into brands (name, address, website)
    values ('Kirkland Signature', 'Distributed by Costco Wholesale Corporation, Seattle, WA, USA', 'www.costco.com')
    returning id
),
product_9 as (
    insert into products (brand_id, name, regulatory_pathway, is_seed_sku)
    select brand_kirkland.id, 'Kirkland Signature Extra Strength Vitamin D3 2000 IU (UPC 0 96619 39391 6)', 'supplement_gmp', true
    from brand_kirkland
    returning id
)
insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
select product_9.id, null, null,
    'DSLD label record (id 62677, retrieved 2026-07-23) shows two contacts: "Distributed by: '
    || 'Costco Wholesale Corporation" (a P.O. Box, not a street address), and a second contact '
    || 'literally typed "Manufacturer" with no name or address at all -- just a generic phone '
    || 'line ("Vitamin Infoline," 1-800-428-7782). No legal entity name is disclosed to attempt '
    || 'an FDA Data Dashboard search.',
    'Zero candidates to link -- a major national retailer''s private label showing the same '
    || 'opacity pattern as small marketplace sellers.'
from product_9;

-- ----------------------------------------------------------------------------
-- #11 — Spring Valley Turmeric Curcumin 500 mg (Walmart) (unresolved)
-- ----------------------------------------------------------------------------
with brand_sv as (
    insert into brands (name, address, website)
    values ('Spring Valley', 'Wal-Mart Stores, Inc., Bentonville, AR, USA', 'www.walmart.com/springvalley')
    returning id
),
product_11 as (
    insert into products (brand_id, name, regulatory_pathway, is_seed_sku)
    select brand_sv.id, 'Spring Valley Turmeric Curcumin 500 mg (UPC 6 81131 15679 0)', 'supplement_gmp', true
    from brand_sv
    returning id
)
insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
select product_11.id, null, null,
    'DSLD label record (id 239820, retrieved 2026-07-23): "Distributed by: Wal-Mart Stores, Inc., '
    || 'Bentonville, AR" -- no manufacturer disclosed at all. FDA Data Dashboard import_refusals '
    || '(retrieved 2026-07-23) shows 335 total refused shipments under turmeric-related product '
    || 'codes, mostly raw turmeric spice/extract from India-based exporters unrelated to '
    || 'Walmart''s actual supplier -- real category-level context, but import REFUSALS are '
    || 'distinct from import ALERTS (standing DWPE orders) per the schema''s own definitions; the '
    || 'import_alerts table stays empty since that needs Tier 4 (manual-only) CMS_IA data.',
    'Zero candidates to link. Category-level import scrutiny exists for turmeric broadly but '
    || 'cannot be tied to this specific product''s actual supplier.'
from product_11;

-- ----------------------------------------------------------------------------
-- #12 — Cellucor C4 Original, Cherry (unresolved)
-- ----------------------------------------------------------------------------
with brand_cellucor as (
    insert into brands (name, address, website)
    values ('Cellucor', 'Distributed by Nutrabolt, Austin, TX, USA', 'www.Cellucor.com')
    returning id
),
product_12 as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select brand_cellucor.id, 'Cellucor C4 Original, Cherry (UPC 8 42595 13469 8)', 'supplement_gmp',
        '{
            "servingSize": "1 Scoop",
            "proprietaryBlends": [
                {
                    "name": "Muscular Endurance and Performance Booster",
                    "components": ["CarnoSyn", "Velox Patented Performance Blend", "PeptiPump Bioactive Lentil Peptides"],
                    "note": "Individual component doses not disclosed"
                },
                {
                    "name": "Explosive Energy and Focus Complex",
                    "components": ["Caffeine Anhydrous", "Toothed Clubmoss Aerial Parts Extract"],
                    "note": "Toothed Clubmoss is a Huperzine A source with real regulatory/NDI history; individual doses not disclosed"
                }
            ]
        }'::jsonb,
        true
    from brand_cellucor
    returning id
)
insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
select product_12.id, null, null,
    'DSLD label record (id 335104, retrieved 2026-07-23): "Cellucor and C4 are trademarks of and '
    || 'Distributed by: Nutrabolt, Austin, TX" (Nutrabolt actually owns the Cellucor brand, not '
    || 'merely a distributor). FDA Data Dashboard returns zero results for both "Nutrabolt" and '
    || '"Cellucor" as legal names -- a well-evidenced null, both variants checked.',
    'Zero candidates to link. Two proprietary blends confirmed in the ingredient structure, '
    || 'including a Huperzine-A-source ingredient worth an NDI-log follow-up (Tier 4, manual only, '
    || 'not verified here).'
from product_12;
