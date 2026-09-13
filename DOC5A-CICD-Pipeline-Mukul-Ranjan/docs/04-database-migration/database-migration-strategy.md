# Database Migration Strategy --- NovaPay Digital Bank

**Day 6 \| Deliverable 4 \| PostgreSQL 16 \| 100M+ financial rows \|
Zero planned downtime**

## 1. Objective

NovaPay needs schema changes without downtime while Application V(N-1)
and V(N) may temporarily run together. The assessment requires an
expand-contract strategy, PostgreSQL examples, pgroll research, gh-ost
comparative research, 100M+ row backfill, ACID considerations,
compatibility matrix, DBA governance, online migration tooling,
throttling, and phase-level rollback.

``` text
V(N-1)
  |
  v
EXPAND --> MIGRATE --> CONTRACT
  |          |           |
safe DDL   backfill   remove old
  |        + throttle   schema
  +---- backward compatibility ----+
```

## 2. Design Principles

-   No maintenance window for normal migrations.
-   Every schema change is backward compatible until old versions are
    retired.
-   Never perform destructive schema changes during the initial
    application rollout.
-   Backfills are idempotent, batched and throttled.
-   Large-table operations use online/non-blocking techniques where
    appropriate.
-   CONTRACT is a separate forward-only deployment with its own approval
    gate.
-   Every migration produces audit evidence.
-   Financial data integrity and ACID properties must be preserved.
-   Automatically abort if migration impact increases query latency by
    more than 20%.

## 3. Example Migration

Existing table:

``` sql
CREATE TABLE customer_profiles (
    id BIGINT PRIMARY KEY,
    email TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

New schema adds `encrypted_email` while retaining `email` during the
compatibility window.

## 4. EXPAND Phase

Add new structures without breaking V(N-1).

``` sql
-- V2.0__expand_add_encrypted_email.sql

BEGIN;

ALTER TABLE customer_profiles
ADD COLUMN IF NOT EXISTS encrypted_email BYTEA;

COMMIT;

CREATE INDEX CONCURRENTLY IF NOT EXISTS
idx_customer_profiles_encrypted_email
ON customer_profiles (encrypted_email);
```

The assessment reference uses this same pattern and explicitly says not
to drop the old `email` column during EXPAND.

Audit record:

``` sql
INSERT INTO schema_audit_log
    (migration_id, description, executed_by, phase)
VALUES
    ('V2.0', 'Add encrypted_email column', current_user, 'EXPAND');
```

### EXPAND PASS

-   DDL completed.
-   No unacceptable lock wait.
-   Query latency impact \<=20%.
-   V(N-1) remains healthy.
-   Audit evidence exists.

### EXPAND rollback

If the new objects are unused:

``` sql
ALTER TABLE customer_profiles
DROP COLUMN IF EXISTS encrypted_email;
```

Do not remove the column if V(N) has already written data that exists
only there.

## 5. MIGRATE Phase

Backfill existing records without taking the database offline.

The assessment reference uses a 1,000-row batch with
`FOR UPDATE SKIP LOCKED`.

### 100M+ row strategy

Never use one giant transaction.

``` text
100M+ rows
    |
    v
Select batch
    |
    v
Transform / encrypt
    |
    v
Commit
    |
    v
Measure DB + application health
    |
    +-- Healthy --> continue
    |
    +-- Degraded -> throttle / pause
    |
    +-- >20% latency impact -> STOP + alert DBA
```

  Parameter                    Initial value
  ------------- ----------------------------
  Batch size                      1,000 rows
  Workers                        1 initially
  Transaction      One batch per transaction
  Locking           `FOR UPDATE SKIP LOCKED`
  Retry                           Idempotent
  Throttling         Adjust to database load
  Abort           Query latency impact \>20%

The 1,000-row starting batch comes from the assessment reference;
production sizing must be validated with production-scale pre-production
testing.

### PostgreSQL backfill example

``` sql
-- V2.1__migrate_backfill_encrypted_email.sql

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

        RAISE NOTICE 'Migrated % rows; total: %',
            batch_count, total_migrated;

        EXIT WHEN batch_count = 0;

        PERFORM pg_sleep(0.1);
    END LOOP;
END $$;
```

### Idempotency

Use a deterministic condition such as:

``` sql
WHERE encrypted_email IS NULL
```

A retry must not duplicate financial records or produce an incorrect
final state.

## 6. Adaptive Throttling

Monitor:

-   Query latency.
-   Lock wait time.
-   CPU.
-   Disk I/O.
-   Database connections.
-   Replication lag where applicable.
-   Application errors.
-   Payment transaction latency.

``` text
Run batch
   |
   v
Measure health
   |
   +-- Healthy --> continue
   |
   +-- Degraded -> reduce batch / pause
   |
   +-- >20% impact -> stop + alert DBA
```

## 7. CONTRACT Phase

Remove obsolete schema only after all dependent services have migrated.

``` sql
-- V2.2__contract_remove_old_email.sql

BEGIN;

ALTER TABLE customer_profiles
DROP COLUMN email;

COMMIT;
```

CONTRACT is forward-only and requires a separate approval gate.

### CONTRACT prerequisites

-   V(N-1) is no longer running.
-   All services use V(N).
-   Backfill is 100% complete.
-   New data is validated.
-   No service references the old column.
-   Production verification passed.
-   DBA approval is recorded.
-   Recovery capability is confirmed.
-   Audit evidence exists.

### Contract recovery

There is no normal destructive rollback after the old column is removed.
Validate first, confirm recovery readiness, obtain separate approval,
then execute CONTRACT.

## 8. Version Compatibility Matrix

  Schema state               App V(N-1)   App V(N)   Meaning
  -------------------------- ------------ ---------- ----------------------------------
  S0 --- Old schema          PASS         FAIL       V(N) cannot depend on new schema
  S1 --- Expanded            PASS         PASS       Both versions compatible
  S2 --- Backfill running    PASS         PASS       New field partially populated
  S3 --- Backfill complete   PASS         PASS       Validate before cutover
  S4 --- V(N) only           Retired      PASS       Old version removed
  S5 --- Contracted          Retired      PASS       Old schema removed

**Never enter S5 while V(N-1) can still execute.**

## 9. Application Deployment Sequence

### Release 1 --- EXPAND

``` text
DB: add encrypted_email
App: unchanged
```

### Release 2 --- Compatible application

V(N) can use the new schema while V(N-1) remains functional.

### Release 3 --- MIGRATE

``` text
Existing rows
    |
    v
encrypted_email
    |
    v
100% validated
```

### Release 4 --- CONTRACT

``` text
Retire V(N-1)
     |
     v
Remove old schema
```

## 10. Online Migration Tool Selection

### PostgreSQL --- pgroll

Primary online schema-migration tool for the PostgreSQL design.

Controls:

-   Test in development.
-   Validate in staging.
-   Test with production-scale data in pre-production.
-   Require DBA review.
-   Monitor locks and query latency.
-   Capture migration output as evidence.
-   Stop if the \>20% latency threshold is reached.

### MySQL --- gh-ost

The assessment includes gh-ost in the research scope as an online
migration approach. NovaPay targets PostgreSQL, so gh-ost is comparative
research rather than the primary production tool.

  Database     Tool                      NovaPay role
  ------------ ------------------------- --------------------------
  PostgreSQL   pgroll                    Primary
  MySQL        gh-ost                    Comparative
  MySQL        pt-online-schema-change   Alternative
  PostgreSQL   Native DDL                Small compatible changes

## 11. Migration Governance

``` text
Developer
   |
Migration PR
   |
Automated validation
   |
Peer review
   |
DBA approval
   |
Pre-production test
   |
Compliance / change approval
   |
Production migration
   |
Verification
   |
Audit evidence
```

### DBA review checklist

-   [ ] Unique migration version.
-   [ ] SQL peer reviewed.
-   [ ] Backward compatibility confirmed.
-   [ ] Lock behavior assessed.
-   [ ] Index/DDL impact tested.
-   [ ] Backfill is idempotent.
-   [ ] Batch size tested.
-   [ ] Throttling defined.
-   [ ] Abort threshold configured.
-   [ ] Recovery procedure documented.
-   [ ] Pre-production test completed.
-   [ ] Production-scale test completed.
-   [ ] Audit evidence location defined.
-   [ ] Change/approval reference exists.

## 12. Segregation of Duties

  Role                   Responsibility
  ---------------------- --------------------------------------
  Developer              Creates migration
  Tech Lead / Reviewer   Reviews compatibility
  DBA                    Reviews database safety and approves
  Compliance             Reviews evidence where required
  Release Manager        Authorises release
  SRE                    Monitors production

## 13. ACID Requirements

### Atomicity

Each controlled migration transaction completes fully or rolls back.
Large backfills use independently committed batches rather than one
giant transaction.

### Consistency

Maintain primary-key uniqueness, foreign-key validity, required
financial fields, account/payment invariants and correct business
totals.

### Isolation

Migration work must not unsafe­ly interfere with live payment
transactions. Use short transactions and appropriate locking.

### Durability

Committed financial changes must survive failures according to the
database durability and recovery configuration.

## 14. Financial Data Validation

Before and after migration compare:

-   Row counts.
-   Null counts.
-   Deterministic checksums/comparisons where appropriate.
-   Business totals.
-   Account/payment consistency.
-   Application transaction results.
-   Database health.
-   Encryption state.

``` text
Baseline
   |
Migration
   |
Validation
   |
PASS --> continue
FAIL --> stop / remediate
```

## 15. Rollback / Recovery by Phase

  -------------------------------------------------------------------------
  Phase             Failure           Action              Recovery
  ----------------- ----------------- ------------------- -----------------
  EXPAND            DDL failure       Stop                Remove unused
                                                          objects

  EXPAND            Latency \>20%     Abort + alert       Remove unused
                                                          objects after
                                                          validation

  MIGRATE           Batch failure     Retry               Idempotent retry

  MIGRATE           DB degradation    Pause/throttle      Resume after
                                                          recovery

  MIGRATE           Validation        Stop                Correct and
                    failure                               re-run

  MIGRATE           Application       Freeze              Keep
                    failure                               compatibility
                                                          schema

  CONTRACT          Pre-check failure Do not execute      Remain in S4

  CONTRACT          Destructive issue Incident/recovery   Approved DB
                                                          recovery
                                                          procedure
  -------------------------------------------------------------------------

## 16. Production Execution

### Pre-flight

1.  Approved change ticket.
2.  DBA approval.
3.  Backup/recovery readiness.
4.  Application compatibility confirmed.
5.  Monitoring active.
6.  Abort thresholds configured.
7.  Recovery procedure ready.

### Execution

``` text
EXPAND
  ↓
Verify
  ↓
Deploy compatible application
  ↓
MIGRATE
  ↓
Monitor + throttle
  ↓
Validate 100%
  ↓
Retire V(N-1)
  ↓
CONTRACT
  ↓
Verify
```

## 17. Migration Decision Gates

### Gate 1 --- EXPAND

**PASS:** schema added, V(N-1) healthy, no blocking issue, latency
impact \<=20%.

**FAIL:** DDL failure, lock contention, application errors, or latency
impact \>20%.

### Gate 2 --- MIGRATE

**PASS:** backfill progressing, database healthy, no unacceptable
application degradation, data validation correct.

**FAIL:** inconsistency, sustained DB degradation, latency impact \>20%,
or payment/business transaction failure.

### Gate 3 --- CONTRACT

**PASS:** backfill 100%, V(N-1) retired, all services use V(N),
validation complete, DBA approval recorded.

**FAIL:** old-version dependency, incomplete validation, recovery
dependency, or missing approval.

## 18. Audit Evidence

Record:

``` text
Migration ID
Commit SHA
Application version
Database version
Migration phase
Executed by
Approved by
Start timestamp
End timestamp
Rows processed
Batch size
Observed latency
Pause/abort events
Validation result
Change ticket
Recovery decision
Final status
```

Example:

``` json
{
  "migration_id": "V2.1",
  "phase": "MIGRATE",
  "application_version": "2.1.0",
  "commit_sha": "<commit-sha>",
  "executed_by": "<service-or-user>",
  "approved_by": "<dba>",
  "batch_size": 1000,
  "rows_processed": 100000000,
  "status": "PASS"
}
```

## 19. CI/CD Integration

``` text
Source
  ↓
Build
  ↓
Tests
  ↓
Security gates
  ↓
Compliance gates
  ↓
Migration validation
  ↓
DBA approval
  ↓
EXPAND
  ↓
Application deployment
  ↓
MIGRATE
  ↓
Health verification
  ↓
CONTRACT approval
  ↓
CONTRACT
```

This replaces unmanaged manual database/deployment activity with a
controlled, auditable migration workflow.

## 20. Repository Structure

``` text
docs/
└── 04-database-migration/
    ├── database-migration-strategy.md
    └── migrations/
        ├── V2.0__expand_add_encrypted_email.sql
        ├── V2.1__migrate_backfill_encrypted_email.sql
        └── V2.2__contract_remove_old_email.sql
```

## 21. Day 6 Completion Checklist

-   [x] Expand-contract pattern
-   [x] PostgreSQL examples
-   [x] pgroll online migration design
-   [x] gh-ost comparative research
-   [x] 100M+ row backfill strategy
-   [x] Batch sizing and throttling
-   [x] Version compatibility matrix
-   [x] DBA approval gate
-   [x] Migration review checklist
-   [x] ACID requirements
-   [x] Rollback/recovery per phase
-   [x] Audit evidence
-   [x] CI/CD integration

## 22. Final Strategy

``` text
             ZERO-DOWNTIME MIGRATION

                  EXPAND
                    |
          Add compatible schema
                    |
                    v
             V(N-1) + V(N)
                    |
                    v
                 MIGRATE
                    |
        100M+ rows, batch + throttle
                    |
                    v
              100% validated
                    |
                    v
                CONTRACT
                    |
            Remove old schema
                    |
                    v
                 V(N) only
```

**Primary safety rule:** Never perform a destructive schema change until
every application version that depends on the old schema has been
retired and the new data has been fully validated.

This is the Day 6 Deliverable 4 strategy required by the assessment.

## Complete migration flow

```

                 Migration Request
                         │
                         ▼
                    DBA Review
                         │
                         ▼
                 Compatibility Check
                         │
                         ▼
                      EXPAND
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
            PASS                   FAIL
              │                     │
              ▼                     ▼
          MIGRATE                Rollback
              │
              ▼
        Batch + Throttle
              │
              ▼
       Monitor DB Metrics
              │
        ┌─────┴─────┐
        ▼           ▼
     Healthy     >20% latency
        │           │
        ▼           ▼
     Continue      Abort
        │
        ▼
      Validate
        │
        ▼
  All services on V(N)?
        │
        ▼
   CONTRACT Approval
        │
        ▼
     CONTRACT
        │
        ▼
   Final Validation



   ---

## Cross-Deliverable References

- [Deliverable 1 — Pipeline Architecture](../01-pipeline-architecture/architecture.md)
- [Deliverable 3 — Compliance Gates](../03-compliance-gates/compliance-gates.md)
- [Deliverable 5 — Environment Promotion](../05-environment-promotion/environment-promotion-workflow.md)
- [Deliverable 6 — Rollback Specification](../06-rollback-specification/rollback-specification.md)
- [Deliverable 8 — Observability](../08-observability/observability-strategy.md)