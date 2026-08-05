-- ============================================================================
-- PROVENIX — Migration 009: public methodology versioning.
--
-- Implements provenix_excipient_personalization_spec_v0.5.md Build Prompt
-- 3.3. Closes a gap flagged while building 3.1/3.2: Build Prompt 3.3 assumes
-- "scores already carry their methodology version" -- they didn't. This
-- migration makes that true, retroactively for existing rows too, rather
-- than only going forward from here.
--
-- is_current mirrors manufacturer_attributions.is_current from the base
-- schema -- same "exactly one current row, enforced by a partial unique
-- index" pattern, not a new idea.
--
-- 'score_model_v1' is seeded with released_at DERIVED from
-- min(trust_scores.created_at), not a guessed date -- see
-- feedback_provenix_verification_role: don't assert a fact I don't actually
-- have; the earliest real score in the table is the honest answer to "when
-- did this methodology first produce a score."
--
-- scores_affected_count on methodology_changelog is intentionally left for
-- application code to fill in AT INSERT TIME (see
-- scripts/recordMethodologyChangelogEntry.ts), not computed here. The
-- weighting/penalty formulas that determine whether a score "moved" live in
-- TypeScript (scoreProductV1.ts), not SQL -- there is no way to compute this
-- number from inside a migration or a database function. This also respects
-- methodology_changelog's append-only trigger (migration 007): rather than
-- inserting a row and updating it later once a count is known (which the
-- trigger would reject), the count must be known BEFORE the row is
-- inserted.
--
-- Run this after provenix_migration_008_dose_reality_gate.sql.
-- ============================================================================

alter table methodology_versions add column is_current boolean not null default false;
create unique index methodology_versions_one_current on methodology_versions (is_current) where is_current;

alter table methodology_changelog add column scores_affected_count integer;

alter table trust_scores add column methodology_version_id uuid references methodology_versions(id);

-- ----------------------------------------------------------------------------
-- Seed the version that produced every existing score.
-- ----------------------------------------------------------------------------
insert into methodology_versions (version_label, released_at, description, is_current)
select
    'score_model_v1',
    coalesce((select min(created_at)::date from trust_scores), current_date),
    'Original 6-subscore launch weighting (manufacturer_transparency 0.3, '
    || 'regulatory_compliance 0.25, testing_quality 0.15, third_party_certifications '
    || '0.15, ingredient_transparency 0.1, adverse_events 0.05 -- see scoreProductV1.ts). '
    || 'Retroactively assigned to every trust_scores row that predates '
    || 'methodology_version_id existing.',
    false;

update trust_scores
set methodology_version_id = (select id from methodology_versions where version_label = 'score_model_v1')
where methodology_version_id is null;

alter table trust_scores alter column methodology_version_id set not null;

-- ----------------------------------------------------------------------------
-- Seed the version that's live as of this migration: same weights, but
-- regulatory_compliance can now be penalized by excipient regulatory flags
-- (migrations 007/008). is_current=true -- this is what runScoring.ts stamps
-- on every new trust_scores row from here on.
-- ----------------------------------------------------------------------------
insert into methodology_versions (version_label, released_at, description, is_current)
values (
    'score_model_v1_excipient_layer',
    current_date,
    'Same weights as score_model_v1. Adds excipient regulatory flags as a new '
    || 'penalty type inside regulatory_compliance -- no top-level reweight, per '
    || 'provenix_excipient_personalization_spec_v0.5.md decisions log #3.',
    true
);

-- ----------------------------------------------------------------------------
-- Public-facing changelog view (Build Prompt 3.3's last requirement). Plain
-- language, reverse chronological. Underlying tables already carry public
-- read RLS (migration 007) -- security_invoker + an explicit grant here,
-- same pattern as product_excipient_regulatory_flags.
-- ----------------------------------------------------------------------------
create view public_methodology_changelog
with (security_invoker = true) as
select
    c.id,
    v.version_label,
    c.entity_type,
    c.change_type,
    c.summary,
    c.effective_date,
    c.scores_affected_count
from methodology_changelog c
join methodology_versions v on v.id = c.methodology_version_id
order by c.effective_date desc, c.created_at desc;

grant select on public_methodology_changelog to anon, authenticated;

-- ============================================================================
-- NEXT STEPS AFTER RUNNING THIS:
--   1. Confirm trust_scores.methodology_version_id is populated for every
--      existing row (should be -- this migration backfills before adding
--      the NOT NULL constraint, so it fails loudly if it can't).
--   2. Run scripts/recordMethodologyChangelogEntry.ts to log the excipient-
--      layer addition itself as a changelog event, with a real computed
--      scores_affected_count (expected: 0, since no excipient data exists
--      yet -- verify it comes back 0, not just skip checking).
--   3. Build Prompts 3.4 (preference resolution function + UI) and 3.5
--      (product page display, including rendering this changelog) are still
--      pending. The view above is data-ready; nothing renders it yet.
-- ============================================================================
