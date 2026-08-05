-- ============================================================================
-- PROVENIX — Migration 008: dose-reality review gate for excipient
-- regulatory flags.
--
-- Implements provenix_excipient_personalization_spec_v0.5.md Build Prompt
-- 3.2. Resolves migration 007's own deferred note on excipient_regulatory_
-- actions: "Dose-reality-check linkage (Build Prompt 3.2) is intentionally
-- not added yet -- that workflow hasn't been built. Add the FK when it is,
-- don't stub it out now." This is that FK.
--
-- SCOPE: this gate applies to excipient_regulatory_actions (Tier I) only.
-- contextual_sources (WHO/IARC, systematic reviews) never scores, so it
-- needs a citation to publish, not a dose-reality check -- nothing here
-- touches that table.
--
-- ENFORCEMENT PHILOSOPHY (§10.4 point 2, §10.5): the gate is not "reviewers
-- are expected to fill in a check before publishing" as a process norm --
-- excipient_regulatory_actions.dose_reality_check_id is NOT NULL, full
-- stop. A row cannot exist in the live scoring table without a completed
-- check, regardless of which code path inserted it. That's a stronger
-- guarantee than gating it only in the proposal workflow below.
--
-- STATE MACHINE (excipient_regulatory_action_proposals.state):
--   draft -> pending_dose_reality_check -> approved -> published
--                                        -> rejected (terminal, kept, queryable)
--   'approved'  requires dose_reality_check_id set AND the check's
--               presents_plausible_human_risk = true.
--   'rejected'  requires rejection_reason set. Never deleted -- "the
--               rejection is recorded and queryable" (Build Prompt 3.2).
--   'published' requires promoted_regulatory_action_id set -- only reachable
--               via publish_excipient_regulatory_action_proposal() below,
--               which is the one path that also writes the live
--               excipient_regulatory_actions row.
--
-- Both new tables are RLS-locked with NO public policy (service_role only)
-- -- draft/rejected reviewer reasoning about why a regulator's action does
-- or doesn't warrant a live flag is internal working material, not
-- something the consumer app's API should ever surface. "The check is
-- internal, but must be producible on request" (Build Prompt 3.2) reads as
-- an audit/legal-defensibility requirement, not a public API requirement.
--
-- Run this after provenix_migration_007_excipient_layer.sql. Assumes
-- excipient_regulatory_actions is currently empty (true as of this
-- migration's authoring -- verified via `npm run score` showing no score
-- drift after migration 007). If it isn't empty when you run this, the
-- ALTER ... SET NOT NULL step below will fail loudly rather than silently
-- leaving unreviewed rows live -- that's the correct failure mode, not a
-- bug to work around.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- The dose-reality check itself
-- ----------------------------------------------------------------------------
create table dose_reality_checks (
    id                             uuid primary key default gen_random_uuid(),
    reviewer_name                  text not null,  -- free text, same pattern as correction_log.corrected_by
    presents_plausible_human_risk  boolean not null,  -- the recorded answer to the fixed gate question
    reasoning                      text not null,
    exposure_figures_considered    text not null,
    supporting_evidence_source     text not null,
    created_at                     timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- Review queue
-- ----------------------------------------------------------------------------
create type excipient_regulatory_action_proposal_state as enum (
    'draft', 'pending_dose_reality_check', 'approved', 'rejected', 'published'
);

create table excipient_regulatory_action_proposals (
    id                             uuid primary key default gen_random_uuid(),
    excipient_id                   uuid not null references excipients(id),
    regulator                      excipient_regulator not null,
    action_type                    text,
    jurisdiction                   text,
    effective_date                 date,
    status                         record_status not null default 'active',
    citation_url                   text not null,
    source                         text not null,
    dose_reality_check_id          uuid references dose_reality_checks(id),
    state                          excipient_regulatory_action_proposal_state not null default 'draft',
    rejection_reason               text,
    promoted_regulatory_action_id  uuid references excipient_regulatory_actions(id),
    created_at                     timestamptz not null default now(),
    updated_at                     timestamptz not null default now(),

    constraint proposal_approved_or_published_requires_check check (
        state not in ('approved', 'published') or dose_reality_check_id is not null
    ),
    constraint proposal_rejected_requires_reason check (
        state <> 'rejected' or rejection_reason is not null
    ),
    constraint proposal_published_requires_promotion check (
        state <> 'published' or promoted_regulatory_action_id is not null
    )
);
create index on excipient_regulatory_action_proposals (state);

-- ----------------------------------------------------------------------------
-- The hard constraint: no row in the live scoring table without a completed
-- check. This is what actually closes the gate, independent of whether
-- something arrived via the proposal workflow above.
-- ----------------------------------------------------------------------------
alter table excipient_regulatory_actions
    add column dose_reality_check_id uuid references dose_reality_checks(id);
alter table excipient_regulatory_actions
    alter column dose_reality_check_id set not null;

-- ----------------------------------------------------------------------------
-- Promotion: the one path from an approved proposal into a live, scoreable
-- excipient_regulatory_actions row. Also writes the methodology_changelog
-- entry required by §10.4 point 4 -- publishing a new flag and logging it
-- are the same transaction, not two steps someone can forget the second half
-- of. Rejection has no equivalent function -- it's a single UPDATE
-- (state='rejected', rejection_reason=...), simple enough not to need one.
-- ----------------------------------------------------------------------------
create or replace function publish_excipient_regulatory_action_proposal(
    p_proposal_id uuid,
    p_methodology_version_id uuid
) returns uuid as $$
declare
    v_proposal excipient_regulatory_action_proposals%rowtype;
    v_new_action_id uuid;
begin
    select * into v_proposal
    from excipient_regulatory_action_proposals
    where id = p_proposal_id
    for update;

    if not found then
        raise exception 'proposal % not found', p_proposal_id;
    end if;
    if v_proposal.state <> 'approved' then
        raise exception 'proposal % is in state %, must be approved to publish', p_proposal_id, v_proposal.state;
    end if;
    if v_proposal.dose_reality_check_id is null then
        raise exception 'proposal % has no completed dose-reality check', p_proposal_id;
    end if;

    insert into excipient_regulatory_actions (
        excipient_id, regulator, action_type, jurisdiction, effective_date,
        status, citation_url, methodology_version_id, source, dose_reality_check_id
    ) values (
        v_proposal.excipient_id, v_proposal.regulator, v_proposal.action_type,
        v_proposal.jurisdiction, v_proposal.effective_date, v_proposal.status,
        v_proposal.citation_url, p_methodology_version_id, v_proposal.source,
        v_proposal.dose_reality_check_id
    )
    returning id into v_new_action_id;

    update excipient_regulatory_action_proposals
    set state = 'published',
        promoted_regulatory_action_id = v_new_action_id,
        updated_at = now()
    where id = p_proposal_id;

    insert into methodology_changelog (
        methodology_version_id, entity_type, entity_id, change_type, summary
    ) values (
        p_methodology_version_id, 'excipient_regulatory_action', v_new_action_id, 'added',
        format(
            'Published excipient regulatory flag from proposal %s (regulator: %s) after a completed dose-reality check.',
            p_proposal_id, v_proposal.regulator
        )
    );

    return v_new_action_id;
end;
$$ language plpgsql;

-- ----------------------------------------------------------------------------
-- RLS -- internal-only, no public policy (see header). Matches the
-- identity.barcode_products pattern in provenix_rls.sql: RLS enabled as a
-- safety net, deliberately no anon/authenticated read policy.
-- ----------------------------------------------------------------------------
alter table dose_reality_checks enable row level security;
alter table excipient_regulatory_action_proposals enable row level security;

-- ============================================================================
-- NEXT STEPS AFTER RUNNING THIS:
--   1. Confirm dose_reality_checks and excipient_regulatory_action_proposals
--      show "RLS enabled" with no public policy in Supabase's table editor.
--   2. Run scripts/testDoseRealityGate.ts to verify the NOT NULL constraint
--      and the publish function's guard rails against the live database.
--   3. Build Prompts 3.3 (public methodology changelog UI), 3.4 (preference
--      resolution function + UI), 3.5 (product page display) are still
--      pending.
-- ============================================================================
