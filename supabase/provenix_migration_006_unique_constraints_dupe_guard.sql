-- ============================================================================
-- PROVENIX — Migration 006: unique constraints to guard against re-run
-- duplication
--
-- Surfaced by a real incident (2026-08-03): fixing a CTE-scope bug in
-- several seed files made them runnable end-to-end again, and since none
-- of these files have re-run guards, executing one a second time silently
-- re-inserted its brand/product/facility rows -- and since downstream
-- recalls/adverse_event_counts inserts match by brand *name* rather than a
-- specific ID, each re-run's data fanned out across every existing
-- same-named brand row (Vega ended up with 3 brand rows and 78 copies of
-- its 13 real recalls). Cleaned up by hand; this migration prevents a
-- repeat by making the duplicate insert fail loudly (whole transaction
-- rolls back, per observed Supabase SQL editor behavior) instead of
-- succeeding silently.
--
-- brands.name and products.name: every seed file's own convention is
-- "insert once per real brand/product, reuse via SELECT afterward" (see
-- Thorne Vitamin D, Optimum Nutrition Creatine, Nature's Way Alive!) --
-- an exact-name collision in this curated dataset is always either a
-- genuine duplicate-run or a real sister-brand-name collision that this
-- project already handles by using a *different* name (e.g. "Nature's Way
-- Farms" is a distinct brands row from "Nature's Way", not a naming
-- collision this constraint would ever block).
--
-- facilities.fei_number: FDA's own establishment identifier -- two
-- facility rows sharing a real FEI is never correct. Partial index (WHERE
-- fei_number IS NOT NULL) since unresolved-attribution cases legitimately
-- have zero facility rows, not a null-FEI one.
-- ============================================================================

alter table brands add constraint brands_name_key unique (name);
alter table products add constraint products_name_key unique (name);
create unique index facilities_fei_number_key on facilities (fei_number) where fei_number is not null;
