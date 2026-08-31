-- V2.0__expand_add_encrypted_email.sql
-- NovaPay Day 6: EXPAND phase
-- Purpose: Add the new encrypted_email column without breaking V(N-1).

BEGIN;

ALTER TABLE customer_profiles
    ADD COLUMN IF NOT EXISTS encrypted_email BYTEA;

COMMIT;

-- Build the index without taking the table through a normal blocking index build.
-- CREATE INDEX CONCURRENTLY cannot run inside a transaction.
CREATE INDEX CONCURRENTLY IF NOT EXISTS
    idx_customer_profiles_encrypted_email
ON customer_profiles (encrypted_email);

-- Verification:
-- SELECT column_name, data_type
-- FROM information_schema.columns
-- WHERE table_name = 'customer_profiles'
--   AND column_name = 'encrypted_email';
