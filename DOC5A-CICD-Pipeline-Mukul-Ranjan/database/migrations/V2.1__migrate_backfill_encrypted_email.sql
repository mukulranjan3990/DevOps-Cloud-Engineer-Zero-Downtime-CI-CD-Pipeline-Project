-- V2.1__migrate_backfill_encrypted_email.sql
-- NovaPay Day 6: MIGRATE phase
-- Purpose: Backfill encrypted_email in small, restartable batches.
-- Starting batch size: 1,000 rows.
-- Production batch size/worker count must be validated with load testing.

DO $$
DECLARE
    batch_size INT := 1000;
    batch_count INT;
    total_migrated BIGINT := 0;
BEGIN
    LOOP
        UPDATE customer_profiles
        SET encrypted_email =
            pgp_sym_encrypt(
                email,
                current_setting('app.encryption_key')
            )
        WHERE id IN (
            SELECT id
            FROM customer_profiles
            WHERE encrypted_email IS NULL
            ORDER BY id
            LIMIT batch_size
            FOR UPDATE SKIP LOCKED
        );

        GET DIAGNOSTICS batch_count = ROW_COUNT;
        total_migrated := total_migrated + batch_count;

        RAISE NOTICE
            'Migrated % rows; total migrated: %',
            batch_count,
            total_migrated;

        EXIT WHEN batch_count = 0;

        -- Throttle between batches. Tune using production-like load testing.
        PERFORM pg_sleep(0.1);
    END LOOP;
END $$;

-- Completion verification:
-- SELECT
--     COUNT(*) AS total_rows,
--     COUNT(encrypted_email) AS migrated_rows
-- FROM customer_profiles;
--
-- CONTRACT must not proceed until migrated_rows = total_rows.
--
-- Operational rule:
-- Abort/pause the migration if migration-related query latency
-- increases by more than 20%, as defined by the Day 6 assessment.
