-- ============================================================================
-- PROVENIX — Migration 007: excipient layer (regulatory / compatibility /
-- certification / contested) + dietary personalization + methodology
-- versioning.
--
-- Implements provenix_excipient_personalization_spec_v0.5.md Build Prompt
-- 3.1. Read that file for the full rationale; this header only covers
-- schema-specific decisions not obvious from the table definitions.
--
-- NAMING NOTE: the spec's build prompt calls this new Tier-I-regulator table
-- "regulatory_actions" — that name is already taken by migration 004's
-- brand/facility-level table (free-text agency, FTC/state-AG actions, no
-- excipient link). This migration names the new table
-- excipient_regulatory_actions instead. Do not merge these two tables --
-- they answer different questions ("did a regulator act against this
-- facility/brand" vs. "did a Tier-I regulator act against this ingredient")
-- and merging them would reintroduce exactly the fact/opinion blending
-- §10.5 exists to prevent.
--
-- STRUCTURAL SEPARATION (§10.5, enforced here, not by convention):
--   • The scoring view (product_excipient_regulatory_flags, below) joins
--     ONLY product_excipients + excipient_regulatory_actions. It cannot
--     reach contested_excipients or contextual_sources -- they are
--     different tables, never referenced by the view or by
--     scoreRegulatoryCompliance.
--   • contested_excipients has no risk/severity/concern/note column, full
--     stop -- the absence is the feature (§9.3).
--   • contextual_sources (WHO/IARC + peer-reviewed literature) has no
--     score-relevant column either -- its only permitted render target is
--     a footnote or the §9.1.1 multi-source note.
--   • methodology_changelog is append-only, enforced by trigger below, not
--     just by convention.
--
-- Certification icons (§9.4) reuse the existing certifications table rather
-- than a new one -- same reasoning as reusing recalls/warning_letters for
-- undeclared allergens (§9.1.2): don't duplicate an existing, working
-- mechanism for a fact that's the same shape.
--
-- Run this after provenix_schema.sql and every prior migration.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Methodology versioning (created first -- excipient_regulatory_actions
-- references it)
-- ----------------------------------------------------------------------------
create table methodology_versions (
    id            uuid primary key default gen_random_uuid(),
    version_label text not null unique,   -- e.g. 'score_model_v1', 'excipient_layer_v1'
    released_at   date not null default current_date,
    description   text
);

create table methodology_changelog (
    id                     uuid primary key default gen_random_uuid(),
    methodology_version_id uuid not null references methodology_versions(id),
    entity_type            text not null,  -- e.g. 'excipient_regulatory_action', 'certification_category', 'scoring_penalty_type'
    entity_id              uuid,           -- nullable: some entries describe a schema-level change, not one row
    change_type            text not null,  -- 'added' | 'removed' | 'modified'
    summary                text not null,
    effective_date         date not null default current_date,
    created_at             timestamptz not null default now()
);

-- Append-only at the database level (§10.4 point 4, §10.5) -- not just "we
-- promise not to edit it." Any UPDATE or DELETE raises, regardless of role,
-- including service_role (ingestion should INSERT a correction row, never
-- rewrite history).
create or replace function reject_methodology_changelog_mutation()
returns trigger as $$
begin
    raise exception 'methodology_changelog is append-only: % is not permitted', TG_OP;
end;
$$ language plpgsql;

create trigger methodology_changelog_no_update
    before update on methodology_changelog
    for each row execute function reject_methodology_changelog_mutation();

create trigger methodology_changelog_no_delete
    before delete on methodology_changelog
    for each row execute function reject_methodology_changelog_mutation();

-- ----------------------------------------------------------------------------
-- Excipient registry
-- ----------------------------------------------------------------------------
create table excipients (
    id         uuid primary key default gen_random_uuid(),
    name       text not null,
    synonyms   text[] not null default '{}',
    cas_number text,
    e_number   text,
    ins_number text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
create unique index excipients_name_key on excipients (name);

create type excipient_source_method as enum (
    'label_ocr', 'label_filing', 'manufacturer_disclosure', 'user_photo', 'other'
);

create table product_excipients (
    id            uuid primary key default gen_random_uuid(),
    product_id    uuid not null references products(id),
    excipient_id  uuid not null references excipients(id),
    source_method excipient_source_method not null,
    confidence    attribution_confidence,  -- reuses the existing enum (high/moderate/low)
    created_at    timestamptz not null default now(),
    unique (product_id, excipient_id)
);

-- ----------------------------------------------------------------------------
-- §9.1 Regulatory flags -- Tier I only. Every row here is scoreable; there
-- is no regulator-identity filter anywhere in this migration or in the
-- scoring view below (§10.5, decisions log #1).
-- ----------------------------------------------------------------------------
create type excipient_regulator as enum ('FDA', 'EFSA', 'HEALTH_CANADA', 'TGA');

create table excipient_regulatory_actions (
    id                      uuid primary key default gen_random_uuid(),
    excipient_id            uuid not null references excipients(id),
    regulator               excipient_regulator not null,
    action_type             text,   -- e.g. 'removed_from_permitted_list', 'restricted', 'banned'
    jurisdiction            text,   -- e.g. 'EU', 'US', 'Canada', 'Australia'
    effective_date          date,
    status                  record_status not null default 'active',
    citation_url            text not null,
    methodology_version_id  uuid references methodology_versions(id),
    source                  text not null,
    retrieved_at            timestamptz not null default now(),
    created_at              timestamptz not null default now()
    -- Dose-reality-check linkage (Build Prompt 3.2) is intentionally not
    -- added yet -- that workflow hasn't been built. Add the FK when it is,
    -- don't stub it out now.
);

-- ----------------------------------------------------------------------------
-- §9.1.2 Undeclared-allergen attribution -- links an EXISTING recall or
-- warning_letter row to the excipient that caused it. Display attribution
-- only. Deliberately has no path into scoring: the underlying recall/
-- warning_letter row already scores via the existing regulatory_compliance
-- penalty logic, and this table must never create a second, parallel
-- scoring input for the same real-world event.
-- ----------------------------------------------------------------------------
create table allergen_excipient_links (
    id                uuid primary key default gen_random_uuid(),
    excipient_id      uuid not null references excipients(id),
    recall_id         uuid references recalls(id),
    warning_letter_id uuid references warning_letters(id),
    note              text,
    created_at        timestamptz not null default now(),
    constraint allergen_excipient_links_exactly_one_source check (
        (recall_id is not null and warning_letter_id is null) or
        (recall_id is null and warning_letter_id is not null)
    )
);

-- ----------------------------------------------------------------------------
-- §10.1a Contextual sources -- WHO/IARC-type international body statements
-- and peer-reviewed systematic reviews/meta-analyses. Same "contextual
-- display only, never scored" permission as Tier II. No risk, severity, or
-- score-relevant column exists here, deliberately -- there is nowhere to
-- write one even by mistake.
-- ----------------------------------------------------------------------------
create type contextual_source_type as enum ('international_body', 'peer_reviewed_literature');

create table contextual_sources (
    id             uuid primary key default gen_random_uuid(),
    excipient_id   uuid not null references excipients(id),
    source_type    contextual_source_type not null,
    source_name    text not null,  -- e.g. 'WHO/IARC', or the journal/review name
    summary        text not null,
    classification text,           -- e.g. an IARC group, or a review's stated finding
    published_date date,
    citation_url   text not null,
    created_at     timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- §9.2 Compatibility signals -- feeds personal, never-scored flags only
-- (§11's resolution function, Build Prompt 3.4). No path into scoring.
-- ----------------------------------------------------------------------------
create type dietary_attribute_type as enum (
    'porcine', 'bovine', 'fish', 'insect_derived', 'dairy', 'gluten_bearing',
    'alcohol_derived', 'plant_only'
);

create table dietary_attributes (
    id           uuid primary key default gen_random_uuid(),
    excipient_id uuid not null references excipients(id),
    attribute    dietary_attribute_type not null,
    created_at   timestamptz not null default now(),
    unique (excipient_id, attribute)
);

-- ----------------------------------------------------------------------------
-- §9.3 Contested excipients -- listed, and nothing else. Do not add a risk,
-- severity, concern, or note column to this table for "future flexibility."
-- The absence is the feature.
-- ----------------------------------------------------------------------------
create table contested_excipients (
    id           uuid primary key default gen_random_uuid(),
    excipient_id uuid not null references excipients(id) unique,
    listed_since date not null default current_date
);

-- ----------------------------------------------------------------------------
-- §11 Consumer dietary preferences (schema only -- resolution function and
-- RLS-scoped access ship with Build Prompt 3.4). Deliberately consumer-only:
-- no practitioner/B2B table here (decisions log #4, §11.3 -- deferred).
-- ----------------------------------------------------------------------------
create type dietary_practice as enum (
    'halal', 'kosher', 'vegan', 'vegetarian', 'gluten_free', 'carnivore'
);

create table user_dietary_practices (
    id         uuid primary key default gen_random_uuid(),
    user_id    uuid not null references auth.users(id),
    practice   dietary_practice not null,
    created_at timestamptz not null default now(),
    unique (user_id, practice)
);

-- ----------------------------------------------------------------------------
-- §9.4 Certification icons -- extends the EXISTING certifications table
-- rather than creating a parallel one. cert_category is nullable: existing
-- NSF/USP/etc. rows don't get one, only kosher/halal/vegan/non_gmo/
-- gluten_free rows do. certifying_body is free text (same reasoning as
-- regulatory_actions.agency elsewhere in this schema) -- the set of
-- certifying bodies (OU, Star-K, Kof-K, IFANCA, ISNA, GFCO, ...) is
-- open-ended, a small enum would be the wrong shape.
-- ----------------------------------------------------------------------------
create type certification_category as enum ('kosher', 'halal', 'vegan', 'non_gmo', 'gluten_free');

alter table certifications add column cert_category certification_category;
alter table certifications add column certifying_body text;

-- ----------------------------------------------------------------------------
-- Scoring view (§10.5, §10.6) -- the ONLY path from the excipient layer into
-- regulatory_compliance. Joins exclusively product_excipients +
-- excipient_regulatory_actions; cannot reach contested_excipients or
-- contextual_sources by construction. security_invoker so the view runs
-- under the querying role's own RLS, not the view owner's.
-- ----------------------------------------------------------------------------
create view product_excipient_regulatory_flags
with (security_invoker = true) as
select
    pe.product_id,
    era.id            as regulatory_action_id,
    era.excipient_id,
    era.regulator,
    era.action_type,
    era.jurisdiction,
    era.effective_date,
    era.status,
    era.citation_url
from product_excipients pe
join excipient_regulatory_actions era on era.excipient_id = pe.excipient_id;

grant select on product_excipient_regulatory_flags to anon, authenticated;

-- ----------------------------------------------------------------------------
-- RLS -- same blanket public-read / no-public-write pattern as
-- provenix_rls.sql for every reference table. user_dietary_practices is the
-- one exception: personal data, readable/writable only by its own user.
-- ----------------------------------------------------------------------------
alter table methodology_versions        enable row level security;
create policy "public read" on methodology_versions        for select to anon, authenticated using (true);

alter table methodology_changelog       enable row level security;
create policy "public read" on methodology_changelog       for select to anon, authenticated using (true);

alter table excipients                  enable row level security;
create policy "public read" on excipients                  for select to anon, authenticated using (true);

alter table product_excipients          enable row level security;
create policy "public read" on product_excipients          for select to anon, authenticated using (true);

alter table excipient_regulatory_actions enable row level security;
create policy "public read" on excipient_regulatory_actions for select to anon, authenticated using (true);

alter table allergen_excipient_links    enable row level security;
create policy "public read" on allergen_excipient_links    for select to anon, authenticated using (true);

alter table contextual_sources          enable row level security;
create policy "public read" on contextual_sources          for select to anon, authenticated using (true);

alter table dietary_attributes          enable row level security;
create policy "public read" on dietary_attributes          for select to anon, authenticated using (true);

alter table contested_excipients        enable row level security;
create policy "public read" on contested_excipients        for select to anon, authenticated using (true);

alter table user_dietary_practices enable row level security;
create policy "read own practices" on user_dietary_practices
    for select to authenticated using (auth.uid() = user_id);
create policy "write own practices" on user_dietary_practices
    for insert to authenticated with check (auth.uid() = user_id);
create policy "delete own practices" on user_dietary_practices
    for delete to authenticated using (auth.uid() = user_id);

-- ============================================================================
-- NEXT STEPS AFTER RUNNING THIS:
--   1. Confirm every new table shows "RLS enabled" in Supabase's table
--      editor, same sanity check as provenix_rls.sql's own closing note.
--   2. Seed methodology_versions with at least one row (e.g. version_label
--      'excipient_layer_v1') before Build Prompt 3.3's changelog entries
--      have anything to reference.
--   3. Run scripts/testExcipientLayerBoundaries.ts to verify the structural
--      separation actually holds against the live database, not just this
--      file's comments.
--   4. Build Prompts 3.2 (dose-reality gate), 3.3 (methodology versioning
--      UI), 3.4 (preference resolution function + UI), 3.5 (product page
--      display) are all still pending -- this migration only covers 3.1.
-- ============================================================================
