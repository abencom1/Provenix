-- ============================================================================
-- PROVENIX — Seed SKU: Vital Proteins Collagen Peptides
--
-- Batch-3 candidate #2 (collagen category, new to the seed set). Unlike Align
-- (distributor-only, manufacturer undisclosed) or FGO (nothing registered at
-- all), this one converges on a specific facility from two independent
-- sources rather than a label statement:
--   1. Chicago Tribune photo (chicagotribune.com, 2020-10-05), caption:
--      "Reyna Alcala checks labels on the high speed canister line Oct. 1,
--      2020, at Vital Proteins in Franklin Park. Workers were making Vital
--      Proteins' Collagen Peptides product. Vital Proteins is headquartered
--      in Chicago's Fulton Market district." — direct photojournalism of the
--      actual production floor.
--   2. openFDA food-enforcement record for recall F-0969-2023 (retrieved
--      2026-07-24), which lists the recalling firm as "Vital Proteins,
--      3400 Wolf Rd Ste 200, Franklin Park, IL 60131-1328" — the same city
--      named in the 2020 photo, three years later, as the firm's own address
--      of record on a federal filing.
-- No FEI number confirmed: FDA Data Dashboard (inspections_classifications,
-- LegalName="Vital Proteins"/"Vital Proteins LLC"/"Vital Proteins Inc",
-- retrieved 2026-07-24) returns zero matches, but that endpoint only covers
-- facilities with inspection history, so this doesn't contradict the address
-- evidence above — it just means no FEI-tagged inspection record exists
-- under those name variants. Logged as moderate confidence (not high, since
-- no FEI ties this to an official establishment registration) with
-- is_primary = true (address-match convergence from two sources, stronger
-- than a single label statement).
--
-- No parent-company claim (e.g. Nestle) is logged here — that was floated
-- earlier in conversation without a source and is NOT treated as fact.
-- ============================================================================

with brand_vp as (
    insert into brands (name, address, website)
    values (
        'Vital Proteins',
        'Headquartered in Chicago''s Fulton Market district, IL (per Chicago Tribune, retrieved '
        || '2026-07-24); manufacturing/recall address of record: 3400 Wolf Rd Ste 200, Franklin '
        || 'Park, IL 60131-1328 (per openFDA recall F-0969-2023)',
        'www.vitalproteins.com'
    )
    returning id
),
product_vp as (
    insert into products (brand_id, name, regulatory_pathway, ingredient_list, is_seed_sku)
    select
        id,
        'Vital Proteins Collagen Peptides, 24oz plastic canister (UPC 8 57273 00866 6)',
        'supplement_gmp',
        '{
            "servingSize": "not yet confirmed",
            "activeIngredients": [
                {"name": "Bovine Collagen Peptides", "amountPerServing": null, "percentDV": null}
            ],
            "otherIngredients": []
        }'::jsonb,
        true
    from brand_vp
    returning id
),
facility_vp as (
    insert into facilities (name, address, country, fei_number)
    values (
        'Vital Proteins',
        '3400 Wolf Rd Ste 200, Franklin Park, IL 60131-1328',
        'US',
        null
    )
    returning id
),
attribution_vp as (
    insert into manufacturer_attributions (product_id, confidence, source_type, source_detail, reason)
    select
        id,
        'moderate'::attribution_confidence,
        'enforcement_record'::attribution_source,
        'Chicago Tribune photo (chicagotribune.com/2020/10/05/..., retrieved 2026-07-24): captioned '
        || 'photo of a worker on "the high speed canister line" "at Vital Proteins in Franklin '
        || 'Park," making Collagen Peptides. openFDA food enforcement record for recall '
        || 'F-0969-2023 (retrieved 2026-07-24): recalling firm "Vital Proteins," address "3400 Wolf '
        || 'Rd Ste 200, Franklin Park, IL 60131-1328." FDA Data Dashboard (inspections_classifications, '
        || 'LegalName variants of "Vital Proteins," retrieved 2026-07-24) returns zero results — '
        || 'inconclusive, not contradictory, since that endpoint only covers facilities with '
        || 'inspection history.',
        'Two independent sources (2020 photojournalism of the production floor, 2023 federal '
        || 'recall filing) converge on the same Franklin Park, IL address, three years apart — '
        || 'stronger than a single label statement, so is_primary = true despite no confirmed FEI '
        || 'number. Confidence held at moderate rather than high because no official FDA '
        || 'establishment registration record ties this address to an FEI.'
    from product_vp
    returning id
)
insert into manufacturer_attribution_facilities (attribution_id, facility_id, is_primary)
select attribution_vp.id, facility_vp.id, true
from attribution_vp, facility_vp;

-- ----------------------------------------------------------------------------
-- Recall: F-0969-2023, Class II, foreign material (broken lid) contamination
-- Source: openFDA food enforcement API (retrieved 2026-07-24), cross-confirmed
-- against the FDA record text pasted directly by Aaron.
-- ----------------------------------------------------------------------------
insert into recalls (product_id, recall_date, classification, reason, status, source, openfda_ref, retrieved_at)
select
    p.id,
    '2023-06-07'::date,
    'Class II',
    'Potential foreign material contamination: pieces of one blue broken lid may be in one or '
    || 'more canisters. 59,701 canisters affected. Voluntary, firm-initiated. Recall initiated '
    || '2023-04-21, terminated 2024-10-07.',
    'closed'::record_status,
    'openfda_food_enforcement',
    'F-0969-2023',
    now()
from products p
where p.name = 'Vital Proteins Collagen Peptides, 24oz plastic canister (UPC 8 57273 00866 6)';
