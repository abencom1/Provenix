-- ============================================================================
-- PROVENIX — Row Level Security policies
-- Run this AFTER provenix_schema.sql, in the Supabase SQL editor.
--
-- Model:
--   • RLS ON for every table (required — off = world-readable/writable via the API).
--   • Public READ on all reference tables (this data is meant to be shown).
--   • No public WRITE. Data loads and pipeline writes use the service_role key
--     (server-side only), which bypasses RLS — so the app stays read-only
--     without blocking your own ingestion.
--
-- If you later add user-contributed data (e.g. label photos), that table needs
-- per-user policies instead of blanket public read — handle it separately.
-- ============================================================================

-- Helper pattern used below for each public reference table:
--   alter table <t> enable row level security;
--   create policy "public read" on <t> for select to anon, authenticated using (true);

-- ---- Core entities --------------------------------------------------------
alter table brands     enable row level security;
create policy "public read" on brands     for select to anon, authenticated using (true);

alter table facilities enable row level security;
create policy "public read" on facilities for select to anon, authenticated using (true);

alter table products   enable row level security;
create policy "public read" on products   for select to anon, authenticated using (true);

-- ---- Attribution ----------------------------------------------------------
alter table manufacturer_attributions enable row level security;
create policy "public read" on manufacturer_attributions for select to anon, authenticated using (true);

-- ---- Regulatory & compliance ---------------------------------------------
alter table warning_letters      enable row level security;
create policy "public read" on warning_letters      for select to anon, authenticated using (true);

alter table import_alerts        enable row level security;
create policy "public read" on import_alerts        for select to anon, authenticated using (true);

alter table recalls              enable row level security;
create policy "public read" on recalls              for select to anon, authenticated using (true);

alter table form_483s            enable row level security;
create policy "public read" on form_483s            for select to anon, authenticated using (true);

alter table ndi_flags            enable row level security;
create policy "public read" on ndi_flags            for select to anon, authenticated using (true);

alter table adverse_event_counts enable row level security;
create policy "public read" on adverse_event_counts for select to anon, authenticated using (true);

-- ---- Testing & certification ---------------------------------------------
alter table lab_testing    enable row level security;
create policy "public read" on lab_testing    for select to anon, authenticated using (true);

alter table certifications enable row level security;
create policy "public read" on certifications for select to anon, authenticated using (true);

-- ---- Scoring --------------------------------------------------------------
alter table trust_scores    enable row level security;
create policy "public read" on trust_scores    for select to anon, authenticated using (true);

alter table trust_subscores enable row level security;
create policy "public read" on trust_subscores for select to anon, authenticated using (true);

-- ---- Trust infrastructure -------------------------------------------------
alter table correction_log enable row level security;
create policy "public read" on correction_log for select to anon, authenticated using (true);

-- ---- Identity layer (not exposed by default; RLS on as a safety net) ------
alter table identity.barcode_products enable row level security;
-- No public policy: this internal layer isn't exposed through the API unless
-- you explicitly add the `identity` schema to API settings later.

-- ============================================================================
-- Sanity check: in Supabase → Table editor, every table should show the green
-- "RLS enabled" state and no "unrestricted" warning.
-- ============================================================================
