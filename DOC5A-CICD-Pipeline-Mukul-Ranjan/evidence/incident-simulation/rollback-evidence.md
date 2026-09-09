# NovaPay Incident Simulation — Rollback Evidence

**Incident ID:** NOVAPAY-SIM-2026-001  
**Rollback:** Canary traffic rollback to last known healthy release  
**Severity:** SEV-1  
**Status:** Simulated / completed

## 1. Rollback Decision

At T+0:
- HTTP 500 = **12%**;
- rollback threshold = **>5% for 60s**;
- PostgreSQL connection pool = **exhausted**;
- payment gateway timeout = **35%**.

The first two conditions satisfy Category A immediate rollback criteria from the assessment.

**Decision:** Rollback required.

## 2. Evidence Register

| ID | Evidence | Required content | Simulation status |
|---|---|---|---|
| RB-001 | Alert evidence | HTTP 500 = 12% | Defined/captured in simulation |
| RB-002 | DB alert | Pool exhausted | Defined/captured in simulation |
| RB-003 | Payment alert | Timeout = 35% | Defined/captured in simulation |
| RB-004 | Deployment metadata | Release/image digest | Required |
| RB-005 | Known-good release | Previous approved version | Required |
| RB-006 | Rollback event | Canary traffic = 0% | Simulation PASS |
| RB-007 | Routing evidence | Previous version serves traffic | Simulation PASS |
| RB-008 | Kubernetes health | Readiness/liveness | Simulation PASS |
| RB-009 | Smoke tests | Core API verification | Simulation PASS |
| RB-010 | Synthetic payment | End-to-end payment check | Simulation PASS |
| RB-011 | DB verification | Pool recovery | Simulation PASS |
| RB-012 | Timeline | Decision timestamps | Recorded |
| RB-013 | Communication | Stakeholder notifications | Recorded |

> This is simulation evidence. It does not claim that real log/screenshot files exist unless separately generated and stored.

## 3. Eight-Step Rollback Workflow

### 1. Detect
Receive HTTP, database and payment alerts.

### 2. Correlate
Compare canary telemetry with baseline and deployment time.

### 3. Freeze
Stop canary promotion and unrelated production changes.

### 4. Roll back
Set canary traffic to 0% and restore the previous approved release.

### 5. Verify
Run Kubernetes health checks, smoke tests, synthetic payment and infrastructure checks.

### 6. Notify
Update Incident Commander, SRE Lead, CTO, CISO, VP Engineering, Release Manager and relevant business/compliance stakeholders.

### 7. Manage incident
Preserve release IDs, alerts, logs, metrics, decisions and customer-impact evidence.

### 8. Post-mortem
Identify root cause, corrective actions and pipeline-control improvements.

## 4. Rollback Success Criteria

```text
Canary traffic = 0%
AND HTTP 5xx below rollback threshold
AND DB pool healthy
AND payment timeout rate recovered
AND smoke tests PASS
AND synthetic payment PASS
AND no continuing critical alerts
```

If a critical condition remains failed, the incident stays open.

## 5. Verification Checklist

### Application
- [x] Known-good release selected.
- [x] Faulty canary removed from traffic.
- [x] Readiness/liveness verification.
- [x] Smoke-test verification.

### Database
- [x] Pool exhaustion treated as rollback trigger.
- [x] Database health verification required.
- [x] Data integrity must be explicitly checked before real closure.

### Payments
- [x] Gateway timeout monitored.
- [x] Synthetic transaction required.
- [x] Customer-facing flow verified.

### Deployment
- [x] Promotion frozen.
- [x] Canary traffic set to 0%.
- [x] Previous release restored.
- [x] Further rollout blocked.

## 6. Independent Recovery

Rollback should not depend exclusively on the health of the newly deployed application. The recovery path should retain independent ability to change traffic and restore a previously approved release.

This aligns with the assessment's rollback requirements and its Cloudflare case-study lesson that a broken deployment path must not prevent recovery.

## 7. Root-Cause Evidence

Rollback evidence proves containment/recovery, not the exact application bug.

Supported root cause:

> The critical hotfix bypassed staging/environment-promotion validation.

## AI Assistance & Attribution

> AI assistance was used to structure this rollback evidence from the supplied assessment. Evidence requirements are separated from simulation outcomes; no fabricated production screenshots or logs are claimed.
