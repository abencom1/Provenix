-- ============================================================================
-- PROVENIX — Migration 004: add regulatory_actions table
--
-- Surfaced while researching Herbalife (an MLM brand, seeded to stress-test
-- the regulatory-compliance subscore): its SEC 10-K references "the Consent
-- Order entered into with the FTC" — the 2016 FTC pyramid-scheme settlement,
-- arguably the single most important regulatory fact about this brand, and
-- one the existing FDA-specific tables (warning_letters, import_alerts,
-- recalls, form_483s, ndi_flags) have nowhere to hold: their `source`
-- defaults and semantics all assume an FDA origin.
--
-- `agency` is deliberately free text, not an enum: unlike attribution_source
-- or regulatory_pathway (a small, known, stable set of values worth
-- enumerating), the set of non-FDA regulators that could plausibly show up
-- here (FTC, state AGs, FCC, CFPB, foreign regulators for internationally
-- sold brands) is open-ended, and a migration per newly-encountered agency
-- would be the wrong kind of friction for what should be a rare, ad hoc
-- table. Same reasoning as brands.address being free text rather than a
-- structured type.
--
-- Follows the same source/retrieved_at provenance discipline as every other
-- regulatory table in this schema — non-negotiable per the project's data
-- rules, and what lets this feed the regulatory-compliance subscore
-- alongside FDA records rather than sitting outside scoring as a note.
-- ============================================================================

create table regulatory_actions (
    id           uuid primary key default gen_random_uuid(),
    brand_id     uuid references brands(id),
    facility_id  uuid references facilities(id),
    agency       text not null,        -- e.g. 'FTC', state AG name, etc. — free text, see above
    action_type  text,                 -- e.g. 'consent_order', 'settlement', 'injunction'
    issued_date  date,
    status       record_status not null default 'active',
    summary      text,
    url          text,
    source       text not null,
    retrieved_at timestamptz not null default now()
);
