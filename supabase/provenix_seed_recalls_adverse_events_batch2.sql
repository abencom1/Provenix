-- ============================================================================
-- PROVENIX — Recalls and adverse events for the 8 batch-2 brands (openFDA),
-- retrieved 2026-07-23. Run after provenix_seed_skus_batch2.sql.
--
-- Recalls linked to brand_id, not product_id — same reasoning as batch 1.
--
-- Deliberately excluded: recalls found by searching the corporate PARENT
-- name that actually belong to a different SISTER brand under the same
-- manufacturer (Glanbia's "think!" bars, NBTY's Solgar/MET-Rx/Pure Protein
-- recalls, Costco/Walmart food-category recalls unrelated to the supplement
-- SKUs seeded here). Linking those would misattribute one brand's problem to
-- another — see provenix_seed_sku_findings.md for the full reasoning.
--
-- Only NOW Foods and Nordic Naturals have recalls attributable to the actual
-- brand; the other 6 have zero (verified, not unattempted).
-- ============================================================================

with b as (select id from brands where name = 'NOW Foods')
insert into recalls (brand_id, recall_date, classification, reason, status, source, openfda_ref)
select b.id, v.recall_date::date, v.classification, v.reason, 'closed'::record_status,
       'openfda_food_enforcement', v.openfda_ref
from b, (values
    ('2013-11-07', 'Class II', 'Digestive enzyme capsules manufactured by NOW Foods may contain the antibiotic chloramphenicol.', 'F-1537-2014'),
    ('2018-11-06', 'Class III', 'NOW Health Group Inc. initiated a voluntary recall of NOW''s Vitamin B-50 mg 100 Veg Caps product code 0420 because it is mislabeled as Vitamin B-50 mg 100 Veg Caps.', 'F-0682-2019'),
    ('2016-03-18', 'Class II', 'Undeclared soy lecithin in 5 dietary supplements.', 'F-1131-2016'),
    ('2025-05-08', 'Class III', 'Regular yeast was inadvertently packaged as nutritional yeast.', 'F-0936-2025'),
    ('2016-03-18', 'Class II', 'Undeclared soy lecithin in 5 dietary supplements.', 'F-1132-2016'),
    ('2017-01-20', 'Class III', 'Product''s supplement fact panel incorrectly states that the product contains 75 mg (milligrams) of Molybdenum, when it actually contains 75 mcg (micrograms).', 'F-1484-2017'),
    ('2016-03-18', 'Class II', 'Undeclared soy lecithin in 5 dietary supplements.', 'F-1130-2016'),
    ('2024-08-14', 'Class II', 'High mold, yeast, and total viable count.', 'F-1756-2024'),
    ('2016-03-18', 'Class II', 'Undeclared soy lecithin in 5 dietary supplements.', 'F-1133-2016'),
    ('2017-09-05', 'Class II', 'Undeclared gluten found in the product and the product is labeled "Gluten Free".', 'F-3573-2017'),
    ('2013-07-03', 'Class II', 'It has been determined that this product contains an undeclared ingredient, licorice extract, which contains glycyrrhizin derived from licorice root.', 'F-1726-2013'),
    ('2016-03-18', 'Class II', 'Undeclared soy lecithin in 5 dietary supplements.', 'F-1129-2016'),
    ('2024-01-10', 'Class III', 'Amount of Phosphatidyl Serine in product is less than stated on the label.', 'F-0859-2024'),
    ('2025-09-24', 'Class II', 'Undeclared pine nut.', 'H-0034-2026')
) as v(recall_date, classification, reason, openfda_ref);

with b as (select id from brands where name = 'Nordic Naturals')
insert into recalls (brand_id, recall_date, classification, reason, status, source, openfda_ref)
select b.id, v.recall_date::date, v.classification, v.reason, 'closed'::record_status,
       'openfda_food_enforcement', v.openfda_ref
from b, (values
    ('2024-02-07', 'Class II', 'Elevated levels of vitamin D3.', 'F-1109-2024'),
    ('2025-05-02', 'Class III', 'Product is mislabeled.', 'F-0840-2025')
) as v(recall_date, classification, reason, openfda_ref);

with b as (
    select name, id from brands where name in (
        'NOW Foods', 'Optimum Nutrition', 'Nordic Naturals', 'Ritual',
        'Nature''s Bounty', 'Kirkland Signature', 'Spring Valley', 'Cellucor'
    )
)
insert into adverse_event_counts (brand_id, report_count, data_period, source)
select b.id, v.report_count, 'cumulative through 2026-07-23', 'openfda_hfcs'
from b
join (values
    ('NOW Foods', 47),
    ('Optimum Nutrition', 26),
    ('Nordic Naturals', 31),
    ('Ritual', 134),
    ('Nature''s Bounty', 548),
    ('Kirkland Signature', 390),
    ('Spring Valley', 322),
    ('Cellucor', 69)
) as v(brand_name, report_count) on v.brand_name = b.name;
