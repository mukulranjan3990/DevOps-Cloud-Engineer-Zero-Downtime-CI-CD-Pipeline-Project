-- V2.2__contract_remove_email.sql
-- NovaPay Day 6: CONTRACT phase
-- Purpose: Remove the obsolete email column after V(N-1) is retired.
-- WARNING: This is a destructive, forward-only migration.

BEGIN;

ALTER TABLE customer_profiles
    DROP COLUMN email;

COMMIT;

-- PRE-CONTRACT REQUIREMENTS:
-- 1. V(N-1) application is completely retired.
-- 2. All services use V(N).
-- 3. encrypted_email backfill is 100% complete.
-- 4. New-column data validation has passed.
-- 5. No service still references customer_profiles.email.
-- 6. Production health checks have passed.
-- 7. DBA approval and change approval are recorded.
-- 8. Backup/recovery readiness is confirmed.
--
-- IMPORTANT:
-- Do not execute this migration while any application version
-- still depends on the old email column.
--
-- There is no normal destructive rollback after this migration.
-- If recovery is required, use the approved database recovery procedure.
