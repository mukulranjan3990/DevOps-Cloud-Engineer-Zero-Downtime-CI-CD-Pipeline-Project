# Rollback Specification — NovaPay Digital Bank

**Day 8 | Deliverable 6 | Automated Rollback**

## 1. Objective

NovaPay's rollback system is the safety mechanism that allows rapid, zero-downtime releases while protecting customer transactions and the five-nines availability target.

The assessment requires Prometheus alerting/routing, Kubernetes liveness/readiness/startup probes, error-budget burn-rate calculations, SLO-based triggers, incident correlation, three rollback categories, an 8-step rollback workflow, and post-rollback verification. fileciteturn11file0turn11file1

---

## 2. Rollback Architecture

```text
Production Release
       |
       v
Prometheus / Grafana
       |
       v
 Alertmanager
       |
  +----+----+
  |         |
Cat A    Cat B/C
  |         |
Auto      Escalate /
Rollback  Manual
  |         |
  +----+----+
       |
       v
Previous Known-Good Release
       |
       v
Verify + Notify + Incident Evidence
```

**Critical principle:** rollback must be independent of the primary deployment path. If deployment is broken, the rollback mechanism must still work. fileciteturn11file9

---

## 3. Rollback Categories

### Category A — Immediate

**Target: <60 seconds**

| Trigger | Detection | Threshold | Action |
|---|---|---|---|
| HTTP 5xx | Prometheus | >5% for 60s | Immediate rollback |
| Health failure | Kubernetes probes | 3 consecutive failures | Immediate rollback |
| OOMKill | Kubernetes/container metrics | Detected | Immediate rollback |
| CrashLoopBackOff | Kubernetes state | Detected | Immediate rollback |
| DB connection-pool exhaustion | Application/DB metrics | Detected | Immediate rollback |
| Synthetic payment failure | Synthetic monitoring | Critical transaction fails | Immediate rollback |

These thresholds follow the assessment. fileciteturn11file1

### Category B — Escalated

**Target: <15 minutes**

| Trigger | Detection | Threshold | Action |
|---|---|---|---|
| p99 latency | Prometheus | >2× baseline for 5 min | Page on-call |
| Error-budget burn | SLO metrics | >10× normal for 10 min | Escalate |
| Transaction success | Business metric | >2% below baseline | Escalate |
| CPU saturation | Kubernetes/node metrics | >90% for 5 min | Escalate |
| Memory saturation | Kubernetes/node metrics | >85% for 5 min | Escalate |

If no response occurs within the escalation window, auto-rollback according to policy. fileciteturn11file1

### Category C — Manual Decision

Examples:

- Gradual degradation below automated thresholds.
- Customer support reports.
- Retroactive compliance failure.
- Downstream dependency correlation.

```text
Warning
  ↓
Correlate evidence
  ↓
Human decision
  ├── Continue
  └── Rollback
```

---

## 4. SLO and Error-Budget Rollback

For an availability SLO:

```text
SLO = 99.9%

Allowed error rate
= 1 - 0.999
= 0.1%
```

For 30 days:

```text
43,200 total minutes

Error budget
= 43,200 × 0.001
= 43.2 minutes
```

Burn rate:

```text
Burn Rate =
Observed Error Rate / Allowed Error Rate
```

Example:

```text
Observed = 1%
Allowed  = 0.1%

Burn Rate = 10×
```

The assessment uses **>10× normal burn for 10 minutes** as a Category B trigger. fileciteturn11file1

---

## 5. Kubernetes Health Probes

### Startup Probe

Protects slow-starting applications from premature liveness restarts.

```yaml
startupProbe:
  httpGet:
    path: /startup
    port: 8080
  periodSeconds: 5
  failureThreshold: 30
```

### Readiness Probe

Controls whether the pod receives traffic.

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  periodSeconds: 5
  failureThreshold: 3
```

### Liveness Probe

Detects an unhealthy running process.

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  periodSeconds: 10
  failureThreshold: 3
```

A readiness failure removes the pod from traffic; repeated liveness failure can cause Kubernetes to restart it. The assessment specifically requires three consecutive health failures as an immediate rollback trigger. fileciteturn11file1

---

## 6. Prometheus Alerting Examples

```yaml
groups:
  - name: novapay-rollback
    rules:

      - alert: NovaPayHigh5xxRate
        expr: |
          (
            sum(rate(http_requests_total{
              status=~"5..",
              environment="production"
            }[1m]))
            /
            sum(rate(http_requests_total{
              environment="production"
            }[1m]))
          ) > 0.05
        for: 60s
        labels:
          severity: critical
          rollback_category: A
        annotations:
          summary: "Production 5xx rate above 5%"
          action: "Immediate rollback"

      - alert: NovaPayHighP99Latency
        expr: |
          histogram_quantile(
            0.99,
            sum(rate(http_request_duration_seconds_bucket{
              environment="production"
            }[5m])) by (le)
          ) > 2 * novapay:p99_baseline_seconds
        for: 5m
        labels:
          severity: warning
          rollback_category: B
        annotations:
          summary: "p99 latency exceeds 2x baseline"
          action: "Escalate and evaluate rollback"

      - alert: NovaPayHighCPU
        expr: |
          avg(rate(container_cpu_usage_seconds_total{
            environment="production"
          }[5m])) > 0.90
        for: 5m
        labels:
          severity: warning
          rollback_category: B
        annotations:
          summary: "Production CPU above 90%"
          action: "Escalate and evaluate rollback"
```

These are representative rules implementing the assessment's thresholds; actual metric names must match the deployed instrumentation.

---

## 7. Alert Routing

```text
Prometheus
    ↓
Alertmanager
    |
    +--> Category A --> Immediate rollback --> SRE notification
    |
    +--> Category B --> On-call page --> Escalation timer
    |                                      |
    |                                +-----+-----+
    |                                |           |
    |                             Response    No response
    |                                |           |
    |                             Investigate  Auto-rollback
    |
    +--> Category C --> Warning --> Incident channel --> Human decision
```

---

## 8. Incident Correlation

Correlate every rollback signal with:

- Deployment ID.
- Application version.
- Git SHA.
- Image digest.
- Canary/blue-green state.
- Deployment timestamp.
- Kubernetes events.
- Pod restarts.
- Database health.
- Redis health.
- Payment success.
- Downstream dependency status.
- Feature-flag changes.

Example:

```text
15:00 Deployment starts
15:03 Canary = 10%
15:04 5xx increases
15:05 Payment success decreases
15:05 Pod restarts increase
15:06 Category A trigger
15:06 Rollback
```

This determines whether the release is the likely cause rather than an unrelated infrastructure/dependency incident.

---

# 9. Eight-Step Rollback Execution Workflow

The assessment requires this sequence: **detect → correlate → freeze → rollback → verify → notify → incident → postmortem**. fileciteturn11file0

### Step 1 — Detect

Prometheus, Alertmanager, Kubernetes or synthetic monitoring identifies a rollback trigger.

Record:

- Timestamp.
- Metric.
- Threshold.
- Affected release.

### Step 2 — Correlate

```text
Alert
 ↓
Deployment timestamp
 ↓
Version / digest
 ↓
Baseline comparison
 ↓
Dependency health
```

### Step 3 — Freeze

Stop further rollout.

```text
Canary 10%
     ↓
FREEZE
     ↓
Do not promote further
```

### Step 4 — Rollback

Return traffic to the last known-good version.

Blue-green:

```text
Blue 0% / Green 100%
        ↓
Blue 100% / Green 0%
```

Canary:

```text
Canary → 0%
Stable → 100%
```

### Step 5 — Verify

Run:

- Health checks.
- Readiness checks.
- Smoke tests.
- Synthetic payment.
- 5xx verification.
- p99 verification.
- DB health.
- Redis health.
- Payment-success comparison.

### Step 6 — Notify

Notify:

```text
SRE
Release Manager
Incident channel
Engineering leadership
Compliance/business stakeholders when required
```

### Step 7 — Incident

Create/update the incident record:

- Incident ID.
- Severity.
- Start/end time.
- Trigger.
- Release.
- Customer impact.
- Rollback actions.
- Recovery evidence.
- Owners.
- Communications.

### Step 8 — Postmortem

```text
Timeline
 ↓
Root cause
 ↓
Contributing factors
 ↓
Why controls did not prevent it
 ↓
Corrective actions
 ↓
Preventive controls
```

---

## 10. Post-Rollback Verification

The assessment specifically requires **smoke tests, metric comparison and customer impact assessment**. fileciteturn11file0

### Smoke Tests

```text
Health
Readiness
Authentication
Account lookup
Payment initiation
Payment status
Transaction history
Synthetic payment
```

Synthetic payment must verify successful processing and absence of duplicate transactions.

### Metric Comparison

| Metric | Failed Release | Stable Release | Expected |
|---|---|---|---|
| HTTP 5xx | Elevated | Baseline | Return toward baseline |
| p99 latency | Elevated | Baseline | Recover |
| Payment success | Reduced | Baseline | Recover |
| CPU | Elevated | Normal | Recover |
| Memory | Elevated | Normal | Recover |
| DB errors | Elevated | Normal | Recover |
| Pod restarts | Elevated | Stable | Stop increasing |

### Customer Impact

Assess:

- Failed requests.
- Failed payment attempts.
- Affected customers where measurable.
- Duplicate-payment risk.
- Delayed-payment risk.
- Reconciliation requirements.
- Duration of impact.
- Geographic/tenant impact.

**Important banking rule:**

```text
Application rollback
        ≠
Financial transaction rollback
```

Financial transactions require reconciliation and idempotency controls rather than blindly reverting database state.

---

## 11. Blue-Green Rollback

```text
             Istio
               |
       +-------+-------+
       |               |
     BLUE            GREEN
    Stable          Candidate
     100%             0%
```

Normal promotion:

```text
Blue 100% / Green 0%
       ↓
Verify Green
       ↓
Blue 0% / Green 100%
```

Rollback:

```text
Green 100%
    ↓
Trigger
    ↓
Blue 100%
```

The project's deployment design uses this traffic-reversal approach. fileciteturn11file7

---

## 12. Canary Rollback

Canary progression:

```text
1–2%
 ↓
5–10%
 ↓
25–50%
 ↓
100%
```

Every phase:

```text
Measure
  ↓
Gate
 ├── PASS → Next phase
 └── FAIL → Stable 100%
```

For statistical canary analysis, the project uses Welch's t-test for latency and chi-squared analysis for error proportions; statistical significance should be combined with operational thresholds. fileciteturn11file1

---

## 13. Feature-Flag Rollback

```text
Feature ON
    ↓
Failure
    ↓
Production flag OFF
    ↓
Verify stable behavior
```

Progressive rollout:

```text
1% → 10% → 50% → 100%
```

At any failure:

```text
Current percentage → 0%
```

This provides an application-level recovery path without necessarily changing the deployed artifact.

---

## 14. Database Rollback Safety

NovaPay uses:

```text
EXPAND → MIGRATE → CONTRACT
```

Rules:

- EXPAND is backward compatible and can be reversed by removing new objects when safe.
- MIGRATE is idempotent and can be retried.
- CONTRACT is forward-only after obsolete structures are removed.
- CONTRACT requires its own approval gate.
- Migration must abort if query latency impact exceeds **20%**. fileciteturn11file1

Therefore:

```text
Application rollback
       ↓
Return to V(N-1)
       ↓
Keep database compatible
```

Do not automatically execute destructive database rollback scripts during application rollback.

---

## 15. Payment Transaction Draining

A candidate/old pod must not be killed while processing a critical payment.

```text
Rollback
   ↓
Mark pod NotReady
   ↓
Stop new work
   ↓
Drain in-flight requests
   ↓
Complete/recover transactions
   ↓
Close connections
   ↓
Terminate
```

Required protections:

- Idempotency keys.
- Durable transaction state.
- Safe retry/reconciliation.
- No critical state only in memory.
- No duplicate payment on retry.

The project deployment design explicitly requires safe payment draining. fileciteturn11file7

---

## 16. Rollback Decision Matrix

| Category | Trigger | Automatic | Target |
|---|---|---|---|
| A | 5xx >5% for 60s | Yes | <60s |
| A | 3 consecutive health failures | Yes | <60s |
| A | OOMKill | Yes | <60s |
| A | CrashLoopBackOff | Yes | <60s |
| A | DB pool exhaustion | Yes | <60s |
| A | Synthetic payment failure | Yes | Immediate |
| B | p99 >2× baseline for 5m | Escalated | <15m |
| B | Burn rate >10× for 10m | Escalated | <15m |
| B | Payment success >2% below baseline | Escalated | <15m |
| B | CPU >90% for 5m | Escalated | <15m |
| B | Memory >85% for 5m | Escalated | <15m |
| C | Gradual degradation | Manual | Human decision |
| C | Customer reports | Manual | Human decision |
| C | Retroactive compliance issue | Manual | Human decision |
| C | Downstream dependency correlation | Manual | Human decision |

---

## 17. Rollback State Machine

```text
DEPLOYING
   ↓
OBSERVING
   |
   +---- HEALTHY ----> PROMOTE
   |
   +---- TRIGGER ----> CORRELATE
                         ↓
                       FREEZE
                         ↓
                      ROLLBACK
                         ↓
                       VERIFY
                      /      \
                   PASS       FAIL
                    |           |
                    v           v
                 NOTIFY      ESCALATE
                    |           |
                    v           v
                 INCIDENT   INCIDENT/DR
                    |
                    v
                POSTMORTEM
```

---

## 18. Audit Evidence

Every rollback must retain:

```text
Rollback ID
Incident ID
Trigger category
Trigger metric
Threshold
Detection timestamp
Deployment ID
Git SHA
Candidate image digest
Stable image digest
Istio routing state
Argo CD revision
Feature-flag state
Rollback timestamp
Verification results
Customer impact
Escalation/approval records
Final incident status
```

Example:

```json
{
  "rollback_id": "RB-2026-001",
  "category": "A",
  "trigger": "http_5xx_rate",
  "threshold": ">5% for 60s",
  "release": "2.2.0",
  "stable_release": "2.1.0",
  "action": "route_traffic_to_stable",
  "verification": "PASS",
  "customer_impact": "assessed",
  "incident_id": "INC-2026-001"
}
```

---

## 19. Security and Compliance

Rollback must preserve production controls:

- Authenticated rollback identity.
- RBAC-controlled permissions.
- Immutable audit log.
- Approved rollback mechanism.
- Segregated production access.
- Signed image requirements.
- No unapproved production bypass.
- Compliance evidence retained.
- Change/incident reference retained.

The assessment maps RBI change management to testing, approval and rollback procedures and requires segregation of development and deployment responsibilities. fileciteturn11file8

---

## 20. Rollback Testing

Test before production:

1. HTTP 5xx >5%.
2. Three consecutive health failures.
3. OOMKill.
4. CrashLoopBackOff.
5. DB connection exhaustion.
6. p99 >2× baseline.
7. Error-budget burn >10×.
8. Payment success degradation.
9. Feature-flag emergency OFF.
10. Blue-green traffic reversal.
11. Canary rollback.
12. Database migration compatibility scenario.

Success:

```text
Trigger
  ↓
Correct rollback
  ↓
Stable traffic
  ↓
Customer recovery
  ↓
No duplicate payment
  ↓
Evidence generated
```

---

## 21. Day 8 Assessment Checklist

- [x] Prometheus alerting.
- [x] Alert routing.
- [x] Startup probe.
- [x] Readiness probe.
- [x] Liveness probe.
- [x] Error-budget burn rate.
- [x] SLO rollback triggers.
- [x] Incident correlation.
- [x] Category A with 5+ triggers.
- [x] Category B with 4+ triggers.
- [x] Category C manual decision.
- [x] 8-step rollback workflow.
- [x] Smoke-test verification.
- [x] Metric comparison.
- [x] Customer impact assessment.
- [x] Blue-green rollback.
- [x] Canary rollback.
- [x] Feature-flag rollback.
- [x] Database rollback safety.
- [x] Payment transaction draining.
- [x] Audit evidence.
- [x] Rollback testing.

---

## 22. Final Rollback Policy

```text
                    NEW RELEASE
                         |
                         v
                   OBSERVABILITY
                         |
          +--------------+--------------+
          |              |              |
       Category A     Category B     Category C
       Immediate      Escalated       Manual
          |              |              |
          v              v              v
       AUTO-RB       ON-CALL/ESC     HUMAN DECISION
          |              |              |
          +--------------+--------------+
                         |
                         v
                 KNOWN-GOOD RELEASE
                         |
                         v
                POST-ROLLBACK VERIFY
                         |
                    +----+----+
                    |         |
                   PASS      FAIL
                    |         |
                    v         v
                 NOTIFY    ESCALATE
                    |         |
                    +----+----+
                         |
                         v
                    POSTMORTEM
```

> **Core rule:** Detect quickly, correlate the signal with the release, freeze further rollout, return traffic to the last known-good version, verify system and customer recovery, notify stakeholders, create the incident record, and complete a postmortem.

This implements the assessment's **Day 8 — Rollback Specification / Deliverable 6**. fileciteturn10file0turn10file1
