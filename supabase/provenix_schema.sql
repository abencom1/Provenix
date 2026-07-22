-- ============================================================================
-- PROVENIX — Core database schema (v1, maps to Product/MVP doc v0.4)
-- Target: Supabase (PostgreSQL). Paste into the Supabase SQL editor and run.
--
-- Design rules enforced by this schema (from the spec):
--   • Product, Brand, Facility are three DISTINCT objects, never merged (§11.1)
--   • Open Food Facts data lives in its OWN schema and is only LINKED to,
--     never merged with proprietary enrichment — ODbL share-alike (§12.1)
--   • Manufacturer attribution is VERSIONED; old versions are retained (§7.3, §11.1)
--   • "Unresolved manufacturer" is a real, representable state (§7.1)
--   • Import alerts track facility-specific vs category-level SEPARATELY (§7.4, §8.1)
--   • Regulatory pathway field exists from day one for future category expansion (§11.1)
--   • Every enrichment record carries a source + retrieved/verified timestamp (§8.2)
--   • Score WEIGHTS are intentionally NOT in the DB — they live in app logic,
--     so the "minimum viable score" decision does not block the build.
-- ============================================================================

create extension if not exists pgcrypto;   -- for gen_random_uuid()

-- ----------------------------------------------------------------------------
-- LAYER 1 — IDENTITY (ODbL-governed). Sourced from Open Food Facts / GS1.
-- Isolated in its own schema so it is never mixed into proprietary data.
-- The rest of the DB LINKS to it by gtin; it does not copy its fields in.
-- ----------------------------------------------------------------------------
create schema if not exists identity;

create table identity.barcode_products (
    gtin            text primary key,                 -- UPC/GTIN from the barcode scan
    brand_name      text,                             -- as reported by Open Food Facts
    product_name    text,
    raw_off_payload jsonb,                            -- keep the raw source record
    source          text not null default 'open_food_facts',
    retrieved_at    timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- ENUMS
-- ----------------------------------------------------------------------------
create type regulatory_pathway     as enum ('supplement_gmp','food_gmp','conventional_beverage');
create type attribution_confidence as enum ('high','moderate','low');
-- listed in the spec's source-quality priority order (§8, §7.1):
create type attribution_source     as enum ('nsf_listing','enforcement_record','direct_outreach','user_photo','inferred');
create type record_status          as enum ('active','closed');
create type import_alert_scope      as enum ('facility_specific','category_level');
create type f483_source            as enum ('fda_public_subset','redica','fdazilla');
create type lab_testing_tier       as enum (
    'no_testing_claimed',        -- Tier 1
    'claimed_no_public_coa',     -- Tier 2
    'coa_not_per_lot',           -- Tier 3
    'public_per_lot_lookup'      -- Tier 4
);
create type certification_type     as enum ('nsf_ansi_173','nsf_certified_for_sport','usp_verified','informed_sport','informed_choice','other');
create type subscore_type          as enum (
    'manufacturer_transparency',
    'regulatory_compliance',
    'testing_quality',
    'third_party_certifications',
    'ingredient_transparency',
    'adverse_events'
);

-- ----------------------------------------------------------------------------
-- LAYER 2 — CORE PROPRIETARY ENTITIES
-- ----------------------------------------------------------------------------
create table brands (
    id         uuid primary key default gen_random_uuid(),
    name       text not null,
    address    text,
    website    text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table facilities (
    id          uuid primary key default gen_random_uuid(),
    name        text not null,
    address     text,
    country     text,
    fei_number  text,     -- FDA Establishment Identifier, when known
    duns_number text,
    created_at  timestamptz not null default now(),
    updated_at  timestamptz not null default now()
);

create table products (
    id                 uuid primary key default gen_random_uuid(),
    brand_id           uuid not null references brands(id),
    gtin               text references identity.barcode_products(gtin),  -- LINK to identity, not a merge
    name               text not null,
    regulatory_pathway regulatory_pathway not null default 'supplement_gmp',
    ingredient_list    jsonb,                            -- structured ingredient data
    is_seed_sku        boolean not null default false,   -- flags the curated MVP list (50–100 SKUs)
    created_at         timestamptz not null default now(),
    updated_at         timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- LAYER 3 — VERSIONED MANUFACTURER ATTRIBUTION
-- The heart of the product. facility_id NULL = unresolved manufacturer.
-- One row per version; is_current = true marks the live attribution.
-- ----------------------------------------------------------------------------
create table manufacturer_attributions (
    id             uuid primary key default gen_random_uuid(),
    product_id     uuid not null references products(id),
    facility_id    uuid references facilities(id),      -- NULL = unresolved
    confidence     attribution_confidence,              -- NULL when unresolved
    source_type    attribution_source,
    source_detail  text,
    reason         text,                                -- why this version exists / what changed
    effective_from timestamptz not null default now(),
    effective_to   timestamptz,                         -- NULL = still current
    is_current     boolean not null default true,
    created_at     timestamptz not null default now()
);
create index on manufacturer_attributions (product_id) where is_current;

-- ----------------------------------------------------------------------------
-- REGULATORY & COMPLIANCE RECORDS (attached to facility and/or brand/product)
-- Each row records its own source + retrieval time for currency display.
-- ----------------------------------------------------------------------------
create table warning_letters (
    id           uuid primary key default gen_random_uuid(),
    facility_id  uuid references facilities(id),
    brand_id     uuid references brands(id),
    issued_date  date,
    status       record_status not null default 'active',
    url          text,
    summary      text,
    source       text not null default 'fda_warning_letters',
    retrieved_at timestamptz not null default now()
);

create table import_alerts (
    id               uuid primary key default gen_random_uuid(),
    facility_id      uuid references facilities(id),
    scope            import_alert_scope not null,   -- facility_specific weighted higher than category_level
    alert_number     text,
    product_category text,
    issued_date      date,
    status           record_status not null default 'active',
    source           text not null default 'fda_oasis_import_alerts',
    retrieved_at     timestamptz not null default now()
);

create table recalls (
    id           uuid primary key default gen_random_uuid(),
    product_id   uuid references products(id),
    brand_id     uuid references brands(id),
    recall_date  date,
    classification text,                              -- Class I / II / III
    reason       text,
    status       record_status not null default 'active',
    source       text not null default 'fda_recall_rss', -- RSS fires the alert; openFDA supplies detail (§12.1)
    openfda_ref  text,
    retrieved_at timestamptz not null default now()
);

create table form_483s (
    id           uuid primary key default gen_random_uuid(),
    facility_id  uuid references facilities(id),
    issued_date  date,
    source       f483_source not null default 'fda_public_subset', -- full corpus deferred to ~500-SKU trigger
    observations text,
    retrieved_at timestamptz not null default now()
);

create table ndi_flags (
    id                    uuid primary key default gen_random_uuid(),
    product_id            uuid not null references products(id),
    ingredient            text not null,
    expected_notification boolean not null,   -- ingredient type suggests a notice should be on file
    notification_found    boolean not null,   -- was one found in the public NDI log
    note                  text,               -- required "absence is not a violation" context (§12.4)
    source                text not null default 'fda_ndi_log',
    retrieved_at          timestamptz not null default now()
);

create table adverse_event_counts (
    id             uuid primary key default gen_random_uuid(),
    product_id     uuid references products(id),
    brand_id       uuid references brands(id),
    report_count   integer not null default 0,
    data_period    text,                              -- e.g. '2026-Q1'
    source         text not null default 'openfda_hfcs',
    last_refreshed timestamptz not null default now()
    -- Display rule (§12.2): always render with FDA disclaimer context. Enforced in the app, not the DB.
);

-- ----------------------------------------------------------------------------
-- TESTING & CERTIFICATION
-- ----------------------------------------------------------------------------
create table lab_testing (
    id            uuid primary key default gen_random_uuid(),
    product_id    uuid not null references products(id),
    tier          lab_testing_tier not null,
    coa_url       text,
    evidence      text,
    source        text,
    last_verified timestamptz not null default now()
);

create table certifications (
    id            uuid primary key default gen_random_uuid(),
    product_id    uuid not null references products(id),
    cert_type     certification_type not null,
    status        text,                                    -- active / expired / not_found
    cert_url      text,
    source        text not null default 'nsf_manual_lookup', -- manual lookup only per NSF ToS (§12.1)
    last_verified timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- SCORING — values only. Weighting/min-viable rules live in application code.
-- overall_score NULL + is_scorable false  =>  app shows "insufficient data".
-- ----------------------------------------------------------------------------
create table trust_scores (
    id            uuid primary key default gen_random_uuid(),
    product_id    uuid not null references products(id),
    overall_score integer,                            -- 0–100, NULL if not scorable
    is_scorable   boolean not null default true,
    explanation   text,                               -- short "what drove this" summary
    last_verified timestamptz not null default now(),
    created_at    timestamptz not null default now()
);

create table trust_subscores (
    id             uuid primary key default gen_random_uuid(),
    trust_score_id uuid not null references trust_scores(id) on delete cascade,
    subscore_type  subscore_type not null,
    value          integer,                           -- NULL if that dimension has insufficient data
    last_verified  timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- TRUST INFRASTRUCTURE — visible correction log (§5.1, §7.3). Not buried in T&Cs.
-- ----------------------------------------------------------------------------
create table correction_log (
    id             uuid primary key default gen_random_uuid(),
    product_id     uuid not null references products(id),
    attribution_id uuid references manufacturer_attributions(id),
    what_changed   text not null,
    reason         text not null,
    corrected_at   timestamptz not null default now(),
    corrected_by   text
);

-- ============================================================================
-- NEXT STEPS AFTER RUNNING THIS (do before the app reads these tables):
--   1. Enable Row Level Security + add read policies. Supabase exposes every
--      table through an auto-generated API; without RLS they are world-readable
--      AND writable. Most of these are public-read / admin-write — lock that down.
--   2. Add updated_at auto-touch triggers on brands / facilities / products.
--   3. Seed 10–15 SKUs (is_seed_sku = true) with hand-verified data to test the score.
-- ============================================================================
