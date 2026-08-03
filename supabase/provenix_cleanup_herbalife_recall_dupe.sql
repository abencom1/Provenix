-- ============================================================================
-- PROVENIX — Cleanup: duplicate Herbalife recalls insert
--
-- Surfaced by the retailer/press recall re-check pass: Herbalife's
-- regulatory_compliance unexpectedly read 19 instead of the expected ~51,
-- traced to all 4 recalls from provenix_seed_herbalife_backfill.sql being
-- inserted twice (retrieved_at 14:11:32 and 14:22:10 on 2026-08-02, ~11
-- minutes apart -- the apply script was run twice during that session
-- without being noticed, same failure mode as provenix_cleanup_align_
-- dupe.sql's duplicate insert). Deletes the second (later-timestamped) set
-- by explicit UUID, keeping the originals.
-- ============================================================================

delete from recalls where id in (
    'f25904b0-2c6f-45e2-a267-c76123d8318c',
    'afb71cb3-f8d0-430c-82fd-38d930faa2fd',
    '54c3d99e-ad4f-4946-a81e-fab5d08bed63',
    '6fe570fb-f122-424b-a6da-351418759f11'
);
