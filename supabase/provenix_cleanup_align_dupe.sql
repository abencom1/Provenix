-- ============================================================================
-- PROVENIX — Cleanup: duplicate Align insert
--
-- provenix_seed_sku_align.sql's brand+product+attribution CTE chain was run
-- twice, and its lab_testing insert (which matches by product name via LIKE,
-- not by product_id) ran an extra time after the duplicate product already
-- existed, catching both. Result: two full Align brand/product/attribution
-- rows, and 3 lab_testing rows total instead of 1.
--
-- Keeping product 2e54ac93-9414-40dd-a4b5-8d24588ecb21 (brand ff6bc109) as
-- the surviving row. Deleting everything tied to the duplicate
-- (b612c1c9-92a9-4977-8b74-9b9bfe57cae8 / brand 32f80fc1) plus the extra
-- duplicate lab_testing row on the surviving product. No trust_scores exist
-- for either yet, so nothing downstream needs fixing.
--
-- Deletes ordered child-to-parent to respect foreign keys.
-- ============================================================================

delete from lab_testing
where id in (
    'bd493f99-05fa-46e0-b3f9-d3bf693aad75',  -- extra duplicate row on the surviving product
    '59e1257b-873e-4a16-8d72-cfe43b272e22'   -- the duplicate product's own row
);

delete from manufacturer_attributions
where id = 'e394b33c-a7e0-4590-912d-6379aef05f8a';

delete from products
where id = 'b612c1c9-92a9-4977-8b74-9b9bfe57cae8';

delete from brands
where id = '32f80fc1-0abf-4874-999f-496da736a246';

-- ----------------------------------------------------------------------------
-- Verify: should return exactly 1 row for the product, 1 for its
-- attribution, and 1 for lab_testing.
-- ----------------------------------------------------------------------------
select
    (select count(*) from products where id = '2e54ac93-9414-40dd-a4b5-8d24588ecb21') as product_count,
    (select count(*) from manufacturer_attributions where product_id = '2e54ac93-9414-40dd-a4b5-8d24588ecb21') as attribution_count,
    (select count(*) from lab_testing where product_id = '2e54ac93-9414-40dd-a4b5-8d24588ecb21') as lab_testing_count,
    (select count(*) from brands where name = 'Align') as brand_count;
