-- ============================================================================
-- PROVENIX — Seed SKU: Nugenix Total-T Ultimate
--
-- Batch-3 candidate #7 (proprietary-blend test-booster, last of the
-- original batch-3 list). Notable for a distributor/manufacturer split that
-- is unusually well-evidenced from three independent, convergent sources —
-- stronger than the typical "distributed by X, manufacturer undisclosed"
-- pattern (Align, OLLY, Goli).
--
-- Distributor (per label, photo reviewed directly, 2026-07-24): "Distributed
-- by Adaptive Health, Charlotte, NC 28202." Per Aaron: Adaptive Health
-- previously owned Nugenix; both were later acquired by Wellful Inc. Label
-- language is current, not a stale pre-acquisition printing — Adaptive
-- Health appears to be a retained subsidiary/distributor entity name under
-- Wellful's ownership, not evidence the manufacturing facility changed.
--
-- Manufacturer — Biovation Labs, West Valley City, UT — confirmed via three
-- independent sources:
--   1. Wellful's own site (per Aaron, retrieved 2026-07-24): "We manufacture
--      in our very own state of the art, FDA audited, and NSF Certified
--      facility in Salt Lake City, UT..."
--   2. A photo on Wellful's site (per Aaron) names the facility directly:
--      "Biovation Labs," also in the Salt Lake City, UT area.
--   3. Amazon catalog listing (per Aaron) lists "Manufacturer: Biovation"
--      independently — though noting the earlier lesson from Align's
--      "Cavalrywolf" artifact that Amazon catalog fields can be noisy, this
--      one corroborates rather than contradicts the other two sources.
-- FDA Data Dashboard (inspections_classifications, LegalName="Biovation
-- Labs", retrieved 2026-07-24) confirms FEI 1000220648, West Valley City,
-- UT (part of the Salt Lake City metro area, matching the site's looser
-- "Salt Lake City" framing) — a direct, exact legal-name match, unlike the
-- fuzzy-match noise seen for Align/OLLY/Goli.
--
-- Inspection history for this facility (logged separately in
-- inspection_classifications, migration 005) shows 4 OAI (Official Action
-- Indicated — the most serious classification) results between 2010-2017,
-- with the most recent inspection (2023-12-01) coming back NAI (clean) — a
-- real, meaningful compliance signal with an improving trend, not just a
-- single data point.
--
-- No testing/certification claims found in the two label panels reviewed
-- (ingredients + marketing panel) — logged at Tier 1, flagged as based on a
-- partial label review, not a full-product page/site audit.
-- ============================================================================

with brand_nugenix as (
    insert into brands (name, address, website)
    values (
        'Nugenix',
        'Distributed by Adaptive Health, Charlotte, NC 28202 (per product label). Adaptive Health '
        || 'and Nugenix are both owned by Wellful Inc., which manufactures via its own Biovation Labs '
        || 'facility, West Valley City, UT.',
        'www.nugenix.com'
    )
    returning id
),
product_nugenix as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        id,
        'Nugenix Total-T Ultimate, 120 tablets (UPC 855710002925)',
        'supplement_gmp',
        '{
            "servingSize": "4 tablets",
            "servingsPerContainer": 30,
            "activeIngredients": [
                {"name": "Vitamin D (as cholecalciferol)", "amountPerServing": "20mcg", "percentDV": "100%"},
                {"name": "D-Aspartic Acid", "amountPerServing": "3000mg", "percentDV": null},
                {"name": "Tribulus Extract (whole herb and fruit, 95% total saponins)", "amountPerServing": "750mg", "percentDV": null},
                {"name": "Tesnor (R) [proprietary blend: Pomegranate Extract (peel) and Cocoa Extract (bean)]", "amountPerServing": "400mg (blend total; individual component doses not disclosed)", "percentDV": null},
                {"name": "Stinging Nettle Extract (root)", "amountPerServing": "300mg", "percentDV": null},
                {"name": "Maca Extract (root)", "amountPerServing": "250mg", "percentDV": null},
                {"name": "Eurycoma longifolia Extract (root)", "amountPerServing": "150mg", "percentDV": null},
                {"name": "Epimedium Extract (aerial parts, 20% icariins)", "amountPerServing": "100mg", "percentDV": null},
                {"name": "DIM (3,3-Diindolylmethane)", "amountPerServing": "100mg", "percentDV": null},
                {"name": "Boron (as boron glycinate)", "amountPerServing": "10mg", "percentDV": null}
            ],
            "otherIngredients": [
                "Hydroxypropyl cellulose", "Croscarmellose sodium", "Dicalcium phosphate",
                "Stearic acid", "Hypromellose", "Silica", "Glycerin"
            ],
            "note": "Tesnor (R) is a proprietary blend (trademark of Laila Nutra and Gencor) disclosing only the combined 400mg blend weight, not individual Pomegranate vs Cocoa Extract amounts — a real ingredient-transparency limitation, not a data gap on our end."
        }'::jsonb,
        true
    from brand_nugenix
    returning id
),
facility_biovation as (
    insert into facilities (name, address, country, fei_number)
    values ('Biovation Labs', 'West Valley City, UT', 'US', '1000220648')
    returning id
),
attribution_nugenix as (
    insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
    select
        id,
        'high'::attribution_confidence,
        'user_photo'::attribution_source,
        'Wellful Inc. site (per Aaron, retrieved 2026-07-24): "We manufacture in our very own state '
        || 'of the art, FDA audited, and NSF Certified facility in Salt Lake City, UT..." A photo on '
        || 'the same site (per Aaron) names the facility directly: "Biovation Labs." Amazon catalog '
        || 'listing (per Aaron) independently lists "Manufacturer: Biovation." FDA Data Dashboard '
        || '(inspections_classifications, LegalName="Biovation Labs", retrieved 2026-07-24) confirms '
        || 'FEI 1000220648, West Valley City, UT — exact legal-name match, 8 inspection records '
        || '2010-2023. Label itself (photo reviewed directly, 2026-07-24): "Distributed by Adaptive '
        || 'Health, Charlotte, NC 28202" — the brand/distributor entity, not the manufacturer.',
        'is_primary = true given three independent, converging sources naming the same facility '
        || '(company site text, company site photo, and Amazon catalog data) plus an exact FDA '
        || 'legal-name match — stronger convergence than the typical single-source case. Distributor '
        || '(Adaptive Health) and manufacturer (Biovation Labs) are different entities by design, not '
        || 'a gap in our research: per Aaron, Adaptive Health previously owned Nugenix before both '
        || 'were acquired by Wellful Inc., and appears to be a retained subsidiary/distributor name '
        || 'rather than evidence the manufacturing facility changed.'
    from product_nugenix
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select attribution_nugenix.id, facility_biovation.id, true
from attribution_nugenix, facility_biovation;

-- ----------------------------------------------------------------------------
-- Inspection classification history for Biovation Labs (FEI 1000220648),
-- FDA Data Dashboard (inspections_classifications, retrieved 2026-07-24).
-- 4 of 8 inspections classified OAI (Official Action Indicated), the most
-- serious outcome; most recent inspection (2023-12-01) came back clean.
-- ----------------------------------------------------------------------------
insert into inspection_classifications (facility_id, classification, inspection_end_date, source, retrieved_at)
select f.id, v.classification::inspection_classification, v.inspection_end_date::date, 'fda_data_dashboard_inspections_classifications', now()
from facilities f,
     (values
        ('OAI', '2010-03-22'),
        ('VAI', '2011-12-09'),
        ('OAI', '2015-03-02'),
        ('OAI', '2015-03-17'),
        ('VAI', '2016-05-06'),
        ('OAI', '2017-04-10'),
        ('VAI', '2018-05-09'),
        ('NAI', '2023-12-01')
     ) as v(classification, inspection_end_date)
where f.fei_number = '1000220648';

-- ----------------------------------------------------------------------------
-- Lab testing: Tier 1 based on the two label panels reviewed (ingredients +
-- marketing copy) — no CoA, lot-lookup, or testing claim of any kind found.
-- Flagged as a partial-label review, not a full product-page/site audit.
-- ----------------------------------------------------------------------------
insert into lab_testing (product_id, tier, evidence, source, last_verified)
select
    id,
    'no_testing_claimed'::lab_testing_tier,
    'No CoA, lot-lookup tool, or testing claim of any kind found in the two label panels reviewed '
    || '(Supplement Facts + marketing copy panels, 2026-07-24). Based on a partial label review, not '
    || 'a full product-page or brand-site audit — worth re-checking if more of the label or site '
    || 'turns up.',
    'label_review',
    now()
from products
where name = 'Nugenix Total-T Ultimate, 120 tablets (UPC 855710002925)';
