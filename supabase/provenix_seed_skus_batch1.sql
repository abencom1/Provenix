-- ============================================================================
-- PROVENIX — Seed SKU batch 1 (3 of 12): brands, facilities, products,
-- manufacturer_attributions only.
--
-- Scope note: this batch intentionally does NOT populate warning_letters,
-- import_alerts, recalls, form_483s, ndi_flags, adverse_event_counts,
-- lab_testing, certifications, or trust_scores/trust_subscores — none of
-- that has been researched from a primary source for these 3 SKUs yet.
-- Every value below traces to a source logged in provenix_seed_sku_findings.md
-- (retrieved 2026-07-22). Run once — no ON CONFLICT guards, matching the
-- existing schema/RLS scripts' convention (see provenix_schema.sql).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- SKU #1 — Nature Made Vitamin D3 2000 IU (50 mcg) Softgels, Item #2585
-- Manufacturer attribution: UNRESOLVED. Label discloses a distributor only
-- ("Nature Made Nutritional Products, West Hills, CA 91309-9903"); FDA Data
-- Dashboard returns 6 distinct Pharmavite FEI facilities and none can be
-- confidently singled out (West Hills city matches FEI 2018618 but the ZIP
-- does not). facility_id and confidence both NULL per schema's own
-- "unresolved" convention — blank beats guessed.
-- ----------------------------------------------------------------------------
with brand_nature_made as (
    insert into brands (name, address, website)
    values (
        'Nature Made',
        'Nature Made Nutritional Products, West Hills, CA 91309-9903, USA',
        'www.NatureMade.com'
    )
    returning id
),
product_1 as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        id,
        'Nature Made Vitamin D3 2000 IU (50 mcg) Softgels — Item #2585',
        'supplement_gmp',
        '{
            "servingSize": "1 Softgel",
            "activeIngredients": [
                {"name": "Vitamin D3 (Cholecalciferol)", "amountPerServing": "50 mcg (2000 IU)", "percentDV": 250}
            ],
            "otherIngredients": ["Soybean Oil", "Gelatin", "Glycerin", "Water"]
        }'::jsonb,
        true
    from brand_nature_made
    returning id
)
insert into manufacturer_attributions (product_id, facility_id, confidence, source_type, source_detail, reason)
select
    id,
    null,
    null,
    null,
    'Label (screenshot, NatureMade.com, retrieved 2026-07-22) names distributor only: '
    || 'Nature Made Nutritional Products, West Hills, CA 91309-9903. FDA Data Dashboard '
    || '(inspections_classifications, LegalName=Pharmavite LLC, retrieved 2026-07-22) returns '
    || '6 candidate FEI facilities (2016744 San Fernando CA, 2018618 West Hills CA, 2027108 '
    || 'Valencia CA, 3000950981 Santa Clarita CA, 3009943839 Opelika AL, 3030170485 Johnstown OH), '
    || 'all NAI/VAI, none OAI. West Hills city matches FEI 2018618 but ZIP does not '
    || '(label: 91309-9903 vs. facility: 91304) — not strong enough to name a facility.',
    'Company-name matching alone is insufficient to resolve a single facility; no enforcement '
    || 'record, NSF listing, or direct outreach yet ties this specific SKU to one site.'
from product_1;

-- ----------------------------------------------------------------------------
-- SKU #7 — Garden of Life Vitamin Code Women, UPC 6 58010 11417 2
-- Manufacturer attribution: MODERATE. Label distributor address matches an
-- FDA-registered facility's street address/suite/ZIP exactly (city name is a
-- known alias, not a discrepancy) — an inference from registration data, not
-- a document naming brand + facility together, so source_type = 'inferred'
-- per this worksheet's own taxonomy.
-- ----------------------------------------------------------------------------
with brand_gol as (
    insert into brands (name, address, website)
    values (
        'Garden of Life',
        'Garden of Life LLC, 4200 Northcorp Parkway, Palm Beach Gardens, FL 33410, USA',
        'www.gardenoflife.com'
    )
    returning id
),
facility_gol as (
    insert into facilities (name, address, country, fei_number)
    values (
        'Garden Of Life, LLC',
        '4200 Northcorp Pkwy Ste 200, West Palm Beach, FL 33410',
        'US',
        '3011330545'
    )
    returning id
),
product_7 as (
    insert into products (brand_id, name, regulatory_pathway, is_seed_sku)
    select
        brand_gol.id,
        'Garden of Life Vitamin Code — Women (UPC 6 58010 11417 2)',
        'supplement_gmp',
        true
    from brand_gol
    returning id
)
insert into manufacturer_attributions (product_id, facility_id, confidence, source_type, source_detail, reason)
select
    product_7.id,
    facility_gol.id,
    'moderate',
    'inferred',
    'DSLD label record (id 321402, dsldapi.od.nih.gov, retrieved 2026-07-22, on-market) lists '
    || 'distributor "Garden of Life LLC, 4200 Northcorp Parkway, Palm Beach Gardens, FL 33410". '
    || 'FDA Data Dashboard (inspections_classifications, LegalName=Garden of Life LLC, retrieved '
    || '2026-07-22) returns FEI 3011330545 at "4200 Northcorp Pkwy Ste 200, West Palm Beach, FL '
    || '33410" — street address, suite, and ZIP match exactly; city differs (West Palm Beach vs. '
    || 'Palm Beach Gardens) but both refer to the same business park in FDA/USPS records. Two '
    || 'other Garden of Life FEI facilities exist (3010543257 Mangonia Park FL, 3011711592 '
    || 'Freedom PA) that cannot yet be ruled out for this specific SKU.',
    'Address match to a registered facility is stronger than name-matching alone, but a '
    || 'corporate-address registration does not confirm manufacturing/encapsulation happens '
    || 'there rather than at one of the other two registered sites. Not yet confirmed via '
    || 'NSF/USP lookup or direct outreach.'
from product_7, facility_gol;

-- ----------------------------------------------------------------------------
-- SKU #10 (substitute) — Thorne Ashwagandha (Shoden® extract)
-- Manufacturer attribution: HIGH. Label states "manufactured by" (not
-- "distributed by") and names an address matching Thorne's sole registered
-- manufacturing FEI exactly.
-- Note: this SKU is Tier A ("should resolve cleanly"), substituted in for the
-- worksheet's original #10 at Aaron's direction. It does not exercise the
-- facility_id = NULL / is_scorable = false path the worksheet wanted tested
-- before scaling past 3 SKUs — a genuinely unresolved marketplace product is
-- still owed as a follow-up.
-- ----------------------------------------------------------------------------
with brand_thorne as (
    insert into brands (name, address, website)
    values (
        'Thorne',
        'Thorne Research, Inc., Summerville, SC 29486, USA',
        'www.thorne.com'
    )
    returning id
),
facility_thorne as (
    insert into facilities (name, address, country, fei_number)
    values (
        'Thorne Research, Inc.',
        '620 Omni Industrial Blvd, Summerville, SC 29486',
        'US',
        '3014491710'
    )
    returning id
),
product_10 as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        brand_thorne.id,
        'Thorne Ashwagandha',
        'supplement_gmp',
        '{
            "servingSize": "1 Capsule",
            "activeIngredients": [
                {
                    "name": "Ashwagandha extract (root, leaf) (Withania somnifera)",
                    "amountPerServing": "120 mg",
                    "percentDV": null,
                    "note": "Uses the Shoden(R) branded extract from Arjuna Natural Pvt. Ltd."
                }
            ],
            "otherIngredients": ["Microcrystalline Cellulose", "Hypromellose (derived from cellulose) capsule", "Ascorbyl Palmitate"]
        }'::jsonb,
        true
    from brand_thorne
    returning id
)
insert into manufacturer_attributions (product_id, facility_id, confidence, source_type, source_detail, reason)
select
    product_10.id,
    facility_thorne.id,
    'high',
    'user_photo',
    'Label (screenshot, thorne.com product page, retrieved 2026-07-22) states "manufactured by: '
    || 'Thorne Research, Inc., Summerville, SC 29486". FDA Data Dashboard (inspections_classifications, '
    || 'LegalName variants of Thorne Research, retrieved 2026-07-22) returns exactly one manufacturing '
    || 'FEI (3014491710, 620 Omni Industrial Blvd, Summerville, SC 29486, address matches exactly; 7 '
    || 'inspections 2011-2024, mostly NAI, one VAI, none OAI). A second FEI (3016068508) is explicitly '
    || 'labeled "West Coast Distribution Benicia — Thorne Research" and correctly excluded as a '
    || 'distribution, not manufacturing, site.',
    'Direct label statement using "manufactured by" (not "distributed by") matching a single, '
    || 'unambiguous FDA-registered manufacturing facility — the cleanest possible attribution case.'
from product_10, facility_thorne;
