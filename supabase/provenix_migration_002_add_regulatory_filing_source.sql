-- ============================================================================
-- PROVENIX — Migration 002: add 'regulatory_filing' attribution source
--
-- attribution_source previously had five values: nsf_listing,
-- enforcement_record, direct_outreach, user_photo, inferred. None of these
-- properly fit an SEC filing (10-K Properties section, etc.) as a source —
-- surfaced while researching Charlotte's Web Holdings, Inc., whose 10-K
-- names its manufacturing facility (700 Tech Court, Louisville, Colorado)
-- directly. An audited, legally-binding public filing is a stronger source
-- than most of the existing enum values, so it deserves its own category
-- rather than being folded into 'inferred'.
--
-- Purely additive — existing rows/values are unaffected. Postgres does not
-- allow a newly added enum value to be used in the same transaction/script
-- that adds it, so this migration only adds the value; any insert that uses
-- 'regulatory_filing' belongs in a separate, later script.
-- ============================================================================

alter type attribution_source add value 'regulatory_filing';
