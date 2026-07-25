-- ============================================================================
-- PROVENIX — Migration 004b: RLS for regulatory_actions
--
-- migration_004 created the regulatory_actions table but omitted its RLS
-- policy — an oversight against this project's own rule that every table
-- gets an explicit RLS decision before it ships (provenix_rls.sql). Same
-- blanket public-read pattern as every other regulatory/reference table
-- (recalls, warning_letters, etc.): public read, no public write, pipeline
-- writes go through the service_role key.
-- ============================================================================

alter table regulatory_actions enable row level security;
create policy "public read" on regulatory_actions for select to anon, authenticated using (true);
