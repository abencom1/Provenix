-- ============================================================================
-- PROVENIX — Migration 005: add inspection_classifications table
--
-- Surfaced while researching Biovation Labs (Nugenix/Wellful's manufacturing
-- facility, West Valley City, UT, FEI 1000220648): FDA Data Dashboard's
-- inspections_classifications endpoint returns a per-inspection-date NAI/
-- VAI/OAI classification history — a distinct, structured, recurring data
-- type that doesn't fit any existing regulatory table. form_483s is close
-- but expects actual observation text (issued after an OAI/VAI inspection
-- finds objectionable conditions); the classification outcome itself, over
-- time, is a separate and directly queryable signal (e.g. "4 OAI
-- classifications 2010-2017, most recent inspection in 2023 came back
-- clean") that the regulatory-compliance subscore should be able to use
-- without needing full Form 483 text.
--
-- Given this table's clear, small, stable value set (FDA only issues three
-- inspection classifications), it gets its own enum — unlike
-- regulatory_actions.agency, which stays free text because the set of
-- possible non-FDA agencies is open-ended.
--
-- Includes RLS in the same migration this time (unlike migration 004, which
-- had to be patched afterward in 004b) — public read, no public write, same
-- pattern as every other regulatory table.
-- ============================================================================

create type inspection_classification as enum ('NAI', 'VAI', 'OAI');

create table inspection_classifications (
    id                   uuid primary key default gen_random_uuid(),
    facility_id          uuid not null references facilities(id),
    classification       inspection_classification not null,
    inspection_end_date  date,
    source               text not null default 'fda_data_dashboard_inspections_classifications',
    retrieved_at         timestamptz not null default now()
);

alter table inspection_classifications enable row level security;
create policy "public read" on inspection_classifications for select to anon, authenticated using (true);
