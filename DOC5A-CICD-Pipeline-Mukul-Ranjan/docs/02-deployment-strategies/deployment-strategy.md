# NovaPay Deployment Strategy

**Deliverable:** 2 — Deployment Strategies  
**Day:** 4 — Deployment Strategies  
**Primary:** Blue-Green  
**Progressive:** Four-Phase Canary  
**Traffic:** Kubernetes + Istio VirtualService  
**Sessions:** Redis Cluster  
**Observability:** Prometheus + Grafana + Alertmanager  
**Rollback:** Automated return to last known-good release

## 1. Day 4 Objective

Design production-grade zero-downtime deployment strategies for NovaPay.

The assessment requires blue-green deployment with Kubernetes and Istio VirtualService; canary statistical methods using Welch's t-test for latency and chi-squared for error rates; Redis Cluster session management; connection draining and graceful shutdown; a blue-green topology; a five-step traffic-switch protocol; long-running payment draining; a four-phase canary rollout with metrics, thresholds and statistical analysis; and deployment topology diagrams. fileciteturn9file0

---

## 2. Strategy Selection

| Strategy | NovaPay use | Benefit | Risk |
|---|---|---|---|
| Blue-Green | Primary routine production deployment | Fast switch and rollback | Requires duplicate application capacity |
| Canary | High-risk/major changes | Small blast radius and progressive evidence | More operational/statistical complexity |

Both strategies must preserve zero planned downtime, backward-compatible database changes, session continuity, graceful draining, health verification and automated rollback.

---

# 3. Blue-Green Architecture

```text
                  Internet / Mobile / Web
                           |
                    Load Balancer
                           |
                  Istio Ingress Gateway
                           |
                  Istio VirtualService
                    /               \
                   /                 \
              BLUE vN             GREEN vN+1
             Service                Service
              /  \                  /  \
            Pod  Pod              Pod  Pod
              \  /                  \  /
               +--------------------+
                        |
              Shared platform services
                 /        |         \
           PostgreSQL   Redis      RabbitMQ
```

Blue and Green are independent application releases. Shared state remains external to pods.

Normal state:

```text
Blue  = 100%
Green = 0%
```

After successful promotion:

```text
Blue  = 0%
Green = 100%
```

Rollback:

```text
Blue  = 100%
Green = 0%
```

---

# 4. Blue-Green Components

## Kubernetes

Run separate Blue and Green workloads. Identify releases by immutable image digest and Git SHA.

```text
novapay-payment:<version>-<git-sha>
sha256:<immutable-digest>
```

## Istio VirtualService

Istio controls which subset receives traffic.

Conceptual configuration:

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: novapay-payment
spec:
  hosts:
    - novapay-payment
  http:
    - route:
        - destination:
            host: novapay-payment
            subset: green
          weight: 100
        - destination:
            host: novapay-payment
            subset: blue
          weight: 0
```

The production manifest will be implemented later in the IaC/Helm phase.

---

# 5. Five-Step Blue-Green Traffic Switch

## Step 1 — Deploy Green

Deploy the new version beside Blue.

**Gate:** desired replicas available, startup/readiness checks pass, no CrashLoopBackOff.

**Failure:** stop and keep Blue at 100%.

## Step 2 — Verify Green

Run:

- readiness/liveness checks
- smoke tests
- API tests
- dependency checks
- synthetic payment
- database compatibility checks

**Gate:** all blocking checks pass.

**Failure:** repair/remove Green; Blue remains at 100%.

## Step 3 — Drain Connections

Before switching:

```text
Stop new work
   ↓
Mark old pods NotReady
   ↓
Drain connections
   ↓
Complete in-flight requests
   ↓
Safely drain payments
```

Respect Kubernetes termination grace period and application graceful shutdown.

## Step 4 — Switch Istio Traffic

Change:

```text
Before: Blue 100% / Green 0%
After:  Blue 0%   / Green 100%
```

Immediately observe errors, latency, pod health, DB/Redis errors and payment success.

## Step 5 — Observe and Promote

If verification remains healthy:

```text
Green = accepted production version
Blue  = retained rollback version
```

If a rollback trigger occurs, restore traffic to Blue.

---

# 6. Redis Cluster Session Management

Application session state must not depend on pod-local memory.

```text
Client
  |
Istio
  |
+----+----+
|         |
Blue     Green
|         |
+----+----+
     |
 Redis Cluster
     |
Shared session state
```

Requirements:

- Sessions available across Blue and Green.
- Session serialization remains backward compatible.
- Session TTL remains controlled.
- New release must be able to read sessions created by the old release during the transition.
- Avoid incompatible session formats that force logout.

Preferred evolution:

```text
Old + New compatible format
          ↓
      Migration
          ↓
       New format
```

---

# 7. Connection Draining and Graceful Shutdown

```text
SIGTERM
  ↓
Mark NotReady
  ↓
Remove from new routing
  ↓
Stop accepting new work
  ↓
Finish in-flight requests
  ↓
Finish/recover safe transactions
  ↓
Close connections
  ↓
Terminate
```

Controls:

- readiness probe changes before termination
- HTTP connections drain
- database connections close cleanly
- message consumers stop new work before termination
- Redis remains available
- payment state is durable rather than pod-memory dependent

---

# 8. Long-Running Payment Transaction Draining

Payment processing requires special handling.

```text
Deployment starts
      ↓
Old pod NotReady
      ↓
No new payment work
      ↓
Existing transactions continue
      ↓
Completed / safely recoverable
      ↓
Transaction count = 0
      ↓
Terminate old pod
```

Requirements:

- idempotency keys for payment operations
- durable transaction state
- no critical state only in memory
- durable retry/reconciliation path
- retries must not duplicate payments

A deployment must not simply kill a pod because its version is being replaced.

---

# 9. Database Compatibility

Blue and Green can temporarily run different application versions against the same database.

Use:

```text
EXPAND → MIGRATE → CONTRACT
```

### Expand
Add backward-compatible schema objects. Do not immediately remove fields needed by Blue.

### Migrate
Populate new structures with idempotent, throttled operations.

### Contract
Remove obsolete structures only after the old release is no longer required.

The Contract phase is a separate controlled step and should not be coupled blindly to the first traffic switch.

---

# 10. Automated Blue-Green Rollback

## Immediate triggers

| Signal | Trigger |
|---|---|
| HTTP 5xx | >5% for 60 seconds |
| Health | 3 consecutive failures |
| CrashLoopBackOff | Detected |
| OOMKill | Detected |
| DB connection exhaustion | Detected |
| Synthetic payment | Failure |
| Critical application error | Detected |

## Escalation / rollback candidates

| Signal | Threshold |
|---|---|
| p99 latency | >2× baseline for 5 min |
| CPU | >90% for 5 min |
| Memory | >85% for 5 min |
| Payment success | >2% drop |

Final thresholds should be aligned with the later observability/SLO design.

---

# 11. Four-Phase Canary Strategy

Canary progressively exposes the new version.

```text
                    Istio
                      |
             +--------+--------+
             |                 |
          Stable            Canary
           vN                vN+1
             |                 |
             +--------+--------+
                      |
              Prometheus metrics
                      |
              Analysis / decision
                 /          \
             Promote       Rollback
```

## Phase 1 — 1–2%

**Purpose:** catastrophic-failure detection with minimal blast radius.

Metrics:

- 5xx rate
- p95/p99 latency
- restarts
- CPU/memory
- DB errors
- Redis errors
- payment success

Gate: no blocking operational threshold is breached.

Failure: immediate rollback.

## Phase 2 — 5–10%

Compare Canary against Stable.

### Welch's t-test — latency

```text
H0: Canary and Stable latency means are equal.
H1: They differ.
```

Use Welch's test because sample sizes/variances may differ.

Decision:

```text
p < 0.05
AND
observed degradation exceeds the accepted practical threshold
→ do not promote
```

Statistical significance alone is not sufficient; combine it with operational thresholds.

### Chi-squared — errors

Use a 2×2 table:

```text
                 Success   Error
Stable             a         b
Canary             c         d
```

Test whether error outcome differs between groups.

```text
p < 0.05
AND
Canary error rate materially worse
→ fail promotion
```

For very small expected counts, use an appropriate exact test instead of blindly using chi-squared.

## Phase 3 — 25–50%

Validate under larger traffic/load.

Metrics:

- p50/p95/p99
- 5xx and timeout rate
- payment success
- DB latency/connections
- Redis latency/errors
- CPU/memory
- restarts

Repeat Welch and chi-squared analysis and compare business metrics.

Gate: no blocking threshold, unacceptable statistical degradation or critical business degradation.

## Phase 4 — 100%

```text
Stable = 0%
Canary = 100%
```

Final checks:

- health probes
- smoke tests
- synthetic payment
- error rate
- p99 latency
- DB health
- Redis health
- business transaction success
- alert status

Retain the previous stable release for the defined rollback-retention period.

---

# 12. Canary Decision Matrix

| Phase | Traffic | Objective | Analysis | Gate |
|---|---:|---|---|---|
| 1 | 1–2% | Catastrophic-failure detection | Safety metrics | No blocking trigger |
| 2 | 5–10% | Early comparison | Welch + chi-squared | No material degradation |
| 3 | 25–50% | Load validation | Welch + chi-squared + business metrics | Stable vs Canary acceptable |
| 4 | 100% | Full promotion | Continued monitoring | No rollback trigger |

Do not make a statistical decision from an insufficient sample. Require a minimum observation count before statistical tests become authoritative.

---

# 13. Statistical Guardrails

Statistical tests support deployment decisions; they do not replace SLOs.

### Welch's t-test

Use for numeric latency samples from Stable and Canary.

### Chi-squared test

Use for categorical outcomes such as success/error between Stable and Canary.

### Practical significance

A statistically significant difference is not automatically an operational failure. Promotion should consider both:

```text
Statistical evidence
+
Operational threshold
+
Business impact
```

---

# 14. Strategy Comparison

| Requirement | Blue-Green | Canary |
|---|---|---|
| Fast full switch | Excellent | Moderate |
| Fast rollback | Excellent | Excellent |
| Small blast radius | Moderate | Excellent |
| Statistical comparison | Optional | Required in this design |
| Infrastructure cost | Higher | Moderate |
| Operational complexity | Moderate | Higher |
| Routine release | Preferred | Optional |
| High-risk release | Good | Preferred |
| Zero planned downtime | Yes | Yes |

---

# 15. Failure Handling

## Blue-Green

```text
Deploy Green
    ↓
Verify
    ↓
FAIL? ── YES → Keep Blue at 100%
    |
    NO
    ↓
Switch traffic
    ↓
Monitor
    ↓
Threshold breach?
    ├── YES → Rollback to Blue
    └── NO  → Promote Green
```

## Canary

```text
Phase N
  ↓
Measure
  ↓
Gate
 ├── FAIL → Rollback
 └── PASS → Next phase
                ↓
              100%
```

---

# 16. Zero-Downtime Conditions

Zero planned downtime depends on:

- healthy release remains available
- replacement pods pass readiness before traffic
- old connections drain
- long-running payments are safely handled
- sessions are distributed through Redis
- database changes are backward compatible
- Istio controls traffic
- health/SLO metrics are monitored
- rollback returns traffic to known-good release
- sufficient Kubernetes capacity exists for the replacement workload

---

# 17. Day 4 Completion Checklist

- [x] Blue-green deployment design
- [x] Kubernetes topology
- [x] Istio VirtualService traffic management
- [x] Five-step traffic-switch protocol
- [x] Redis Cluster session management
- [x] Connection draining
- [x] Graceful shutdown
- [x] Long-running payment transaction draining
- [x] Expand-contract database compatibility
- [x] Four-phase canary rollout
- [x] Canary metrics and thresholds
- [x] Welch's t-test for latency
- [x] Chi-squared analysis for error rates
- [x] Automated rollback design
- [x] Deployment topology diagrams represented in this document
- [ ] Export standalone topology diagram files if required by your repository workflow
- [ ] Commit: `feat: blue-green and canary deployment specifications`
- [ ] Commit: `docs: deployment topology diagrams`
- [ ] Push Day 4 deliverable

---

## 18. Final Day 4 Repository Location

```text
docs/
└── 02-deployment-strategies/
    └── deployment-strategy.md
```

The assessment's expected output is a **deployment strategy document with diagrams (Deliverable 2)**. fileciteturn9file0
