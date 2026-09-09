# NovaPay Incident Simulation — Incident Metrics

**Incident ID:** NOVAPAY-SIM-2026-001  
**Severity:** SEV-1  
**Scenario:** Friday 5:07 PM IST production canary incident

> **Measurement note:** The assessment supplies the three alert values and rollback thresholds but does not provide a full telemetry dataset. Observed values below are scenario facts; targets/checkpoints are assessment requirements or explicitly simulated values.

## 1. Incident Signals

| Metric | Observed | Threshold / target | Status |
|---|---:|---|---|
| HTTP 500 error rate | **12%** | >5% for 60s = immediate rollback | FAIL / trigger |
| PostgreSQL connection pool | **Exhausted** | Category A trigger | FAIL / trigger |
| Payment gateway timeout | **35%** | Critical degradation signal | FAIL |
| Canary before alerts | **8 min** | First canary phase | Incident detected |
| Rollback initiation | **T+5m** | Project rollback objective <5m | Simulation checkpoint |
| Recovery confirmation | **~T+15m** | Project incident objective <15m | Simulation checkpoint |
| Canary traffic after rollback | **0%** | Faulty release receives no traffic | PASS |
| Data corruption | Not established | Must be explicitly verified | Open verification item |

## 2. Category A Trigger Analysis

The assessment lists immediate Category A triggers including:
- HTTP 5xx >5% for 60s;
- 3 consecutive health-check failures;
- OOM kills;
- CrashLoopBackOff;
- database connection-pool exhaustion.

This simulation directly satisfies:
1. HTTP 500 = 12%, above 5%.
2. PostgreSQL connection-pool exhaustion.

**Decision:** Immediate rollback is justified.

## 3. Payment Risk

Payment-gateway timeout = **35%**. This is treated as a critical end-to-end signal.

Required recovery check:

```text
Synthetic payment
 -> authentication
 -> payment request
 -> gateway interaction
 -> database transaction
 -> customer-visible result
```

**Simulation outcome:** PASS after rollback.

## 4. Response Metrics

| Metric | Assessment / scenario checkpoint |
|---|---|
| Triage/classification | T+30s |
| Communication | T+2m |
| Rollback initiated | T+5m |
| Recovery verification | T+8m |
| Stabilization | ~T+15m |

The assessment's rollback scoring target is **<5 minutes**, with **<2 minutes** as the highest scoring band. This simulation records T+5m as the exercise checkpoint and does not claim elite <2m performance.

## 5. Canary Decision

| Phase | Traffic | Duration | Success criteria | Simulation |
|---|---:|---:|---|---|
| Canary | 1–2% | 15m | Error <0.1%, p99 <200ms | STOP / rollback |
| Early adopter | 5–10% | 30m | Error <0.05%, no critical alerts | Not reached |
| Expansion | 25–50% | 60m | SLOs met | Not reached |
| Full rollout | 100% | 24h bake | Complete SLO compliance | Not reached |

## 6. Post-Rollback Metrics

Verify:
- HTTP 5xx below rollback threshold;
- p99 latency within baseline/SLO;
- DB pool no longer exhausted;
- payment timeout rate recovered;
- readiness/liveness PASS;
- smoke tests PASS;
- synthetic payment PASS;
- no continuing critical alerts.

## 7. DORA/Relevance

The assessment requires:
- Deployment Frequency: multiple per day;
- Lead Time for Changes: <1h elite, project <2h;
- Change Failure Rate: <5%;
- MTTR: <1h DORA table, with the project incident objective of <15m.

The simulation is specifically useful for measuring rollback/MTTR and change-failure learning.

## 8. Evidence Classification

**Assessment-provided:** 12% HTTP 500, DB pool exhausted, 35% payment timeout, 8-minute canary point, Category A thresholds.

**Simulation checkpoints:** T+30s, T+2m, T+5m, T+8m, T+15m and PASS verification outcomes.

## AI Assistance & Attribution

> AI assistance was used to structure this metric evidence from the supplied assessment. No unsupported production telemetry is presented as real data.
