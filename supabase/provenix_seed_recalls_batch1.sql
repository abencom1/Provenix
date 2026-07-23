-- ============================================================================
-- PROVENIX — Recalls for the 4 seed brands (openFDA food/enforcement.json)
--
-- Linked to brand_id, NOT product_id: none of these recalls match our exact
-- seeded SKUs (different dosages/product lines within the same brand). This
-- mirrors the manufacturer_attribution_facilities rollup reasoning — brand-
-- level regulatory history is real and worth showing, but must not be
-- displayed as if it belongs to the specific seeded product.
--
-- source = 'openfda_food_enforcement' (not the schema's default
-- 'fda_recall_rss') because this batch was pulled directly from the openFDA
-- API for historical backfill, not via the RSS-triggered live-alert path
-- described in provenix_schema.sql's comments.
--
-- All records: classification, reason, and recall_number (-> openfda_ref)
-- copied verbatim from openFDA, retrieved 2026-07-22. Some Pharmavite 2014
-- reason_for_recall text is truncated by openFDA's own API (ends mid-
-- sentence) — kept as-is rather than guessing the rest.
--
-- Thorne and FGO: zero recalls found for either — no rows inserted, and
-- that absence is itself a real (if limited) data point, not "no data."
-- ============================================================================

with nm as (select id from brands where name = 'Nature Made'),
     gol as (select id from brands where name = 'Garden of Life')
insert into recalls (brand_id, recall_date, classification, reason, status, source, openfda_ref)
select nm.id, v.recall_date::date, v.classification, v.reason, 'closed'::record_status,
       'openfda_food_enforcement', v.openfda_ref
from nm, (values
    ('2016-06-06', 'Class II', 'Specific lots of Nature Made(R) Vitamin D tablets may exceed specifications for yeast/mold.', 'F-2077-2016'),
    ('2016-06-06', 'Class II', 'Specific lots of Nature Made(R) product may have possible Staphylococcus aureus contamination.', 'F-2070-2016'),
    ('2016-06-06', 'Class II', 'Lot No. 1173146, exp. JUL 2017 of Nature Made(R) product may have possible Staphylococcus aureus contamination.  Lot No 1204001, exp. MAR 2018 of Nature Made(R) product may have possible Salmonella contamination.', 'F-2072-2016'),
    ('2016-06-06', 'Class II', 'Specific lots of Nature Made(R) product may have possible Salmonella contamination.', 'F-2066-2016'),
    ('2013-09-09', 'Class II', 'Pharmavite LLC is conducting a voluntary recall of all lots of its Nature Made Full Strength Mini Multivitamins (recently repackaged as "Multi" softgels, (Multi Complete, Multi for Her, Multi for Her 50+, Multi for Him, Multi Complete club size). because recent quality tests indicate that the Vitamins B1 and B12 are losing potency more rapidly than initially expected, and these products are not me', 'F-0186-2014'),
    ('2013-09-09', 'Class II', 'Pharmavite LLC is conducting a voluntary recall of all lots of its Nature Made Full Strength Mini Multivitamins (recently repackaged as "Multi" softgels, (Multi Complete, Multi for Her, Multi for Her 50+, Multi for Him, Multi Complete club size). because recent quality tests indicate that the Vitamins B1 and B12 are losing potency more rapidly than initially expected, and these products are not me', 'F-0185-2014'),
    ('2016-06-06', 'Class II', 'Specific lots of Nature Made(R) adult gummies Hair.Skin.Nails may exceed specifications total viable plate count.', 'F-2073-2016'),
    ('2016-06-06', 'Class II', 'Specific lots of Nature Made(R) Vitamin D tablets may exceed specifications for yeast/mold.', 'F-2076-2016'),
    ('2016-06-06', 'Class II', 'Lot No. 1170987, exp. JUL 2017 of Nature Made(R) product may have possible Staphylococcus aureus contamination. Lot No1204735, exp. MAR 2018 of Nature Made(R) product may have possible Salmonella contamination.', 'F-2071-2016'),
    ('2016-06-06', 'Class II', 'Specific lots of Nature Made(R) product may have possible Salmonella contamination.', 'F-2068-2016'),
    ('2016-06-06', 'Class II', 'Specific lots of Nature Made(R) product may have possible Salmonella contamination.', 'F-2065-2016'),
    ('2016-06-06', 'Class II', 'Specific lots of Nature Made(R) Vitamin D tablets may exceed specifications for yeast/mold.', 'F-2075-2016'),
    ('2016-06-06', 'Class II', 'Specific lots of Nature Made(R) adult gummies Hair.Skin.Nails may exceed specifications total viable plate count.', 'F-2074-2016'),
    ('2016-06-06', 'Class II', 'Specific lots of Nature Made(R) product may have possible Salmonella contamination.', 'F-2067-2016'),
    ('2013-09-09', 'Class II', 'Pharmavite LLC is conducting a voluntary recall of all lots of its Nature Made Full Strength Mini Multivitamins (recently repackaged as "Multi" softgels, (Multi Complete, Multi for Her, Multi for Her 50+, Multi for Him, Multi Complete club size). because recent quality tests indicate that the Vitamins B1 and B12 are losing potency more rapidly than initially expected, and these products are not me', 'F-0187-2014'),
    ('2016-06-06', 'Class II', 'Specific lots of Nature Made(R) Vitamin D tablets may exceed specifications for yeast/mold.', 'F-2078-2016'),
    ('2016-06-06', 'Class II', 'Specific lots of Nature Made(R) product may have possible Salmonella contamination.', 'F-2069-2016'),
    ('2013-09-09', 'Class II', 'Pharmavite LLC is conducting a voluntary recall of all lots of its Nature Made Full Strength Mini Multivitamins (recently repackaged as "Multi" softgels, (Multi Complete, Multi for Her, Multi for Her 50+, Multi for Him, Multi Complete club size). because recent quality tests indicate that the Vitamins B1 and B12 are losing potency more rapidly than initially expected, and these products are not me', 'F-0184-2014')
) as v(recall_date, classification, reason, openfda_ref)
union all
select gol.id, v.recall_date::date, v.classification, v.reason, 'closed'::record_status,
       'openfda_food_enforcement', v.openfda_ref
from gol, (values
    ('2016-01-29', 'Class I', 'Products possibly contaminated with Salmonella', 'F-1330-2016'),
    ('2016-01-29', 'Class I', 'Products possibly contaminated with Salmonella', 'F-1327-2016'),
    ('2016-01-29', 'Class I', 'Products possibly contaminated with Salmonella', 'F-1329-2016'),
    ('2023-10-19', 'Class II', 'Undeclared Soy.', 'F-0484-2024'),
    ('2017-09-07', 'Class I', 'The product may pose a choking hazard to newborns due to the thickness of the liquid.', 'F-3578-2017'),
    ('2023-10-19', 'Class II', 'Undeclared Soy.', 'F-0482-2024'),
    ('2023-10-19', 'Class II', 'Undeclared Soy.', 'F-0483-2024'),
    ('2016-01-29', 'Class I', 'Products possibly contaminated with Salmonella', 'F-1328-2016')
) as v(recall_date, classification, reason, openfda_ref);
