# NovaPay Incident Simulation — Alert Timeline

**Incident ID:** NOVAPAY-SIM-2026-001  
**Scenario:** Friday 5:07 PM IST production canary incident  
**Severity:** SEV-1 (simulated)  
**Status:** Simulated / resolved

> The assessment specifies a critical hotfix that bypassed staging. Eight minutes into canary deployment, HTTP 500 = 12%, PostgreSQL connection pool is exhausted, and payment-gateway timeout rate = 35%. The timeline below uses the assessment facts plus explicitly identified simulation checkpoints.

## 1. Incident Trigger

At **17:07 IST**, the critical hotfix begins production canary deployment.

At **17:15 IST (T+8m)** the three alerts fire:

| Alert | Observed | Assessment trigger | Severity |
|---|---:|---|---|
| HTTP 500 | 12% | >5% for 60s = Category A rollback | Critical |
| PostgreSQL connection pool | Exhausted | Explicit Category A rollback trigger | High |
| Payment gateway timeout | 35% | Critical payment degradation signal | Critical |

## 2. Timestamped Response

### T+0 — 17:15:00
- Freeze canary promotion.
- Open SEV-1 incident.
- Preserve deployment/alert evidence.
- Identify current canary and previous approved release.
- Begin correlation.

**Decision:** Contain first; do not increase traffic.

### T+30s — 17:15:30
- Confirm customer-facing payment degradation.
- Correlate alerts with active canary.
- Confirm SEV-1.
- Escalate to CTO, CISO and VP Engineering.
- Freeze unrelated production changes.

### T+1m — 17:16:00
Compare canary with baseline:

| Signal | Canary | Result |
|---|---:|---|
| HTTP 5xx | 12% | FAIL |
| DB connection pool | Exhausted | FAIL |
| Payment timeout | 35% | FAIL |
| Canary health | Degraded | FAIL |

**Decision:** Treat the canary as the primary suspected change source.

### T+2m — 17:17:00
Internal incident notification is sent.

> **[SEV-1] NovaPay Production — Payment degradation during canary.** HTTP 500 is 12%, PostgreSQL connection pool is exhausted, and payment gateway timeout is 35%. Canary promotion is frozen and rollback to the last known healthy release is being prepared.

Customer status message:

> **Investigating:** Some customers may experience failed or delayed payment transactions. Engineering is investigating and working to restore normal service.

### T+3m — 17:18:00
Verify rollback target:
- previous approved release;
- image/version metadata;
- provenance;
- previous production success.

**Decision:** Roll back to the last known healthy release.

### T+5m — 17:20:00
Rollback:
1. Freeze promotion.
2. Set canary traffic to 0%.
3. Route traffic to known-good release.
4. Drain affected connections.
5. Stop rollout.
6. Continue monitoring.
7. Preserve rollback evidence.
8. Begin verification.

### T+6m — 17:21:00
- Canary traffic = 0%.
- Previous release serves traffic.
- Error/database/payment signals begin recovering.

### T+8m — 17:23:00
Post-rollback verification:
- readiness/liveness;
- smoke tests;
- synthetic payment;
- database health;
- error rate;
- latency;
- resource saturation.

**Simulation result:** PASS.

### T+10m — 17:25:00
Service remains stable. Faulty release remains quarantined. Root-cause investigation begins.

### T+15m — 17:30:00
**Simulation recovery confirmed.** Continue evidence preservation and corrective-action work.

## 3. Alert-to-Control Mapping

| Event | Pipeline control | Expected protection |
|---|---|---|
| HTTP 500 = 12% | Deployment verification + Category A rollback | Immediate rollback |
| DB pool exhausted | Deployment verification + Category A rollback | Immediate containment |
| Payment timeout = 35% | Synthetic/dependency monitoring | Detect customer impact |
| Hotfix bypassed staging | Environment-promotion gate | Should prevent unsafe promotion |
| Canary | Progressive delivery | Limits blast radius |

## 4. Root-Cause Checkpoint

The assessment does not specify the exact application bug. Therefore no code-level defect is invented.

Supported finding:

> The emergency hotfix reached production after bypassing staging/environment-promotion validation.

Detection and recovery controls worked; the preventive promotion control was bypassed.

## 5. Evidence References

- `incident-metrics.md`
- `rollback-evidence.md`
- `communication-log.md`
- `../incident-simulation-response.md`
- `../post-mortem.md`

## AI Assistance & Attribution

> AI assistance was used to structure this simulation evidence from the supplied assessment. Assessment facts are distinguished from simulated checkpoints. Final validation remains the project author's responsibility.
