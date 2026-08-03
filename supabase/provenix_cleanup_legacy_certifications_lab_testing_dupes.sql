-- ============================================================================
-- PROVENIX — Cleanup: legacy duplicate rows in certifications and lab_testing
--
-- Surfaced by the same recall-recheck pass that found the Herbalife recall
-- duplication (see provenix_cleanup_herbalife_recall_dupe.sql). A systematic
-- check across every table touched this session found two more, predating
-- this session entirely: provenix_certifications_manual_verification.sql
-- and provenix_seed_lab_testing_certifications.sql were each apparently run
-- twice at some point in this project's earlier history, producing exact
-- duplicate rows for all 5 manually-verified certifications and all 12
-- original SKUs' lab_testing rows.
--
-- Severity differs by table:
--   - lab_testing and adverse_event_counts are read with
--     .order(...).limit(1) in scripts/runScoring.ts, so duplicates there
--     never affected any score -- cosmetic clutter only.
--   - certifications has NO such limit -- every matching row is summed via
--     scoreCertifications' activeCount filter. This meant 3 already-
--     scorable products (Nature Made D3, Garden of Life, Optimum Nutrition
--     Whey) had their third_party_certifications subscore silently
--     double-counted (e.g. Nature Made: 1 active cert read as 2, scoring
--     100 instead of the correct 80) since whenever those dupes were
--     introduced. This was a real, live scoring bug, not just untidy data.
--
-- Deletes the later-inserted row of each duplicate pair by explicit UUID,
-- same convention as provenix_cleanup_align_dupe.sql.
-- ============================================================================

delete from certifications where id in (
    '897884e1-b59c-4196-85fe-f721cd635ee1',
    'd03b0406-f2b6-4005-8727-7572d312afcd',
    '31a4dd2e-65d6-4ee0-b1be-40d35dae6e86',
    'cd960343-31c6-422e-bcf9-4a41976a838b',
    '68e7c01e-73d7-47c6-b757-e4637133d5be'
);

delete from lab_testing where id in (
    '14da7eab-f125-4760-a578-016772889a2b',
    '4ad422aa-cb59-4ace-b716-a7d98895e21a',
    '6314510c-6b86-4186-9d4f-a1d66eb79558',
    'b451dc11-9d03-4585-8da6-22e0af058cbb',
    'b8d73dd0-73ad-4129-b252-8a4bc5ded7f9',
    '04bdfb1f-4f2e-48ab-ba69-6c1fe908c439',
    '52ef0b42-f2f5-4c7a-84e8-acb95817eaef',
    'bf0678cf-7041-4b65-8a05-4398f29c3362',
    '1adcbeac-913e-419c-be1e-93bfebc3dc51',
    '28d01da0-9ede-4c45-89f5-4fd85a39d3bd',
    '35a34db7-d2f0-4ede-a9fb-636b2fd6aea2',
    '55cd99d0-ca4f-4dbb-b81b-ff194a3a0755',
    '788efeea-810f-4e49-86cc-c6d6536bfe4e',
    'fdf9c5b9-9902-4e03-970e-e204068c7cf0'
);
