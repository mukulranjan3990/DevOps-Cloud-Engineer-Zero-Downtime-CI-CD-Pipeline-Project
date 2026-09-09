# NovaPay Digital Bank — Incident Simulation Response

**Document:** Day 12 Incident Simulation Response  
**Scenario:** Friday 5:07 PM IST production incident during canary deployment  
**Environment:** Production / Canary  
**Severity:** SEV-1  
**Status:** Simulated and resolved  
**Prepared for:** Technology Risk Committee (TRC) / DevOps & Cloud Engineer Assessment

---

## 1. Purpose

This document records the complete Day 12 incident simulation required by the NovaPay Zero-Downtime CI/CD Pipeline assessment.

The exercise simulates a critical production incident in which a developer pushed a **critical hotfix that bypassed staging**. Eight minutes into the canary deployment, three alerts fired simultaneously:

1. HTTP 500 error rate = **12%**, exceeding the rollback threshold of 5%.
2. PostgreSQL primary connection pool = **exhausted**.
3. Downstream payment gateway timeout rate = **35%**.

The assessment requires every decision, communication, action, timestamp, root-cause finding, and pipeline improvement to be documented.

> **Important:** All timestamps in this document are simulated exercise timestamps, not real NovaPay production events.

---

## 2. Assessment Scenario

The assessment scenario states that it is **Friday at 5:07 PM IST** and a critical hotfix was pushed while bypassing staging. The canary had been running for eight minutes when the three alerts fired.

The expected response is an incident-playbook execution with:

- immediate severity classification,
- rapid triage,
- incident communication,
- automated rollback,
- post-rollback verification,
- root-cause identification,
- identification of the missing/bypassed pipeline control,
- and a post-mortem.

The assessment specifically expects the response timeline to include checkpoints such as **T+0, T+30 seconds, T+2 minutes and T+5 minutes**.

---

## 3. Incident Classification

### 3.1 Severity

**SEV-1 — Critical**

Reason:

- customer-facing payment functionality is affected;
- HTTP 500 errors are far above the immediate rollback threshold;
- the PostgreSQL connection pool is exhausted;
- downstream payment processing is timing out;
- there is potential for transaction failure and customer impact;
- the incident occurs in a banking production environment.

The assessment's incident framework defines SEV-1 as a **complete service outage or data-integrity risk**, with a response target of **less than 5 minutes** and escalation to **CTO + CISO + VP Engineering**.

### 3.2 Initial incident objectives

1. Protect customer transactions.
2. Stop further traffic from reaching the faulty canary.
3. Prevent duplicate or inconsistent payment processing.
4. Restore the last known healthy application version.
5. Verify database and payment-system health.
6. Establish a reliable incident timeline.
7. Preserve evidence for audit and post-mortem analysis.
8. Identify why the unsafe hotfix reached production.

---

## 4. Alert-to-Pipeline Mapping

| Alert | Observed condition | Relevant control | Expected response |
|---|---|---|---|
| HTTP 500 = 12% | >5% for the simulated incident | Deployment verification + Category A rollback trigger | Immediate traffic rollback |
| PostgreSQL pool exhausted | Connection pool exhaustion | Deployment verification, application health metrics, Category A rollback trigger | Stop canary, restore healthy version, protect DB |
| Payment gateway timeout = 35% | Severe downstream transaction degradation | Synthetic transaction monitoring + dependency monitoring + rollback correlation | Roll back and validate payment flow |
| Hotfix bypassed staging | Promotion-control violation | Environment promotion workflow / change-management gate | Production promotion must be blocked |

### Key observation

The production monitoring and rollback controls **did detect the incident**, but the earlier environment-promotion control that should have prevented the unsafe release was bypassed.

The assessment explicitly states that emergency hotfixes may use an expedited path, but they must **not bypass the security and compliance gates**.

---

## 5. Expected Pipeline Protection

The intended NovaPay flow is:

```text
Developer
   |
   v
Source Control
   |
   v
Build + Unit Tests
   |
   +--------------------+
   |                    |
   v                    v
SAST              Dependency/Container Scan
   |                    |
   +---------+----------+
             |
             v
Integration + Contract Tests
             |
             v
DAST
             |
             v
Policy + Compliance Gates
             |
             v
Development
             |
             v
Staging
             |
             v
Pre-Production
             |
       Dual Approval
             |
             v
Production Canary
             |
             v
Automated Verification
             |
        +----+----+
        |         |
      Healthy   Unhealthy
        |         |
        v         v
 Progressive    Rollback
 Promotion        |
                  v
             Incident Response
```

### Where the simulated control failed

The hotfix **bypassed staging**. That means the normal environment-promotion validation was not allowed to execute before production.

This is a process/control failure, not a failure of the canary detection mechanism.

---

# 6. Incident Timeline

## T+0 — 17:15:00 IST — Alerts fire

Three alerts fire simultaneously:

- HTTP 500 rate: **12%**
- PostgreSQL connection pool: **exhausted**
- Payment gateway timeout rate: **35%**

### Automated action

The canary controller immediately evaluates the rollback policy.

The HTTP 500 rate is more than twice the defined immediate rollback threshold:

```text
Observed: 12%
Threshold: >5% for 60 seconds
```

The database connection-pool exhaustion is also explicitly listed as a Category A immediate rollback trigger.

### Decision

**Declare SEV-1 and freeze further canary promotion.**

No traffic increase is permitted.

### Evidence captured

- deployment ID;
- Git SHA;
- container image digest;
- canary percentage;
- alert IDs;
- Prometheus metric snapshots;
- Kubernetes events;
- application logs;
- database connection metrics;
- payment-gateway error/timeout metrics.

---

## T+30 seconds — 17:15:30 IST — Triage and severity classification

The on-call SRE confirms:

- the incident started after the hotfix canary began;
- the affected version is the current canary version;
- the previous production version is healthy;
- database connectivity is degraded;
- payment requests are timing out downstream.

### Decision

**SEV-1 confirmed.**

The incident commander is assigned.

### Immediate safeguards

1. Freeze canary promotion.
2. Stop additional deployment changes.
3. Prevent unrelated production releases.
4. Preserve the failed deployment metadata.
5. Prepare traffic re-routing to the last known healthy version.
6. Verify whether payment requests are still in flight.

---

## T+1 minute — 17:16:00 IST — Correlation

The SRE compares the canary and baseline:

| Metric | Baseline | Canary observation | Result |
|---|---:|---:|---|
| HTTP 5xx | <5% | 12% | FAIL |
| PostgreSQL pool | Healthy | Exhausted | FAIL |
| Payment gateway timeout | Normal baseline | 35% | FAIL |
| Canary health | Healthy expected | Degraded | FAIL |

The three signals are temporally correlated with the hotfix deployment.

### Decision

Treat the deployment as the primary suspected change source until proven otherwise.

---

## T+2 minutes — 17:17:00 IST — Communication

### Internal incident notification

**Subject:** `[SEV-1] NovaPay Production — Payment degradation during canary`

> SEV-1 incident declared at 17:15 IST.  
> HTTP 500 rate is 12%, PostgreSQL connection pool is exhausted, and payment gateway timeout rate is 35%.  
> Canary promotion is frozen and rollback to the last known healthy version is in progress.  
> Incident Commander: SRE on-call.  
> CTO, CISO and VP Engineering escalation initiated.  
> Next update: within 30 minutes or immediately upon material recovery/change.

### Customer/status communication

Because customer-facing payment functionality is degraded, the status process is activated.

The customer message should avoid exposing internal infrastructure details:

> **Investigating:** Some customers may experience failed or delayed payment transactions. Our engineering team is actively investigating and working to restore normal service.

---

## T+3 minutes — 17:18:00 IST — Rollback preparation

The rollback controller identifies:

```text
Current canary:
novapay-app:<new-release>

Known-good release:
novapay-app:<previous-approved-release>
```

The previous version is verified against:

- signed image/provenance;
- deployment manifest;
- Git SHA;
- release metadata;
- previously successful production status.

### Decision

Rollback to the **last known healthy, approved release**.

No manual code change is introduced during recovery.

---

## T+5 minutes — 17:20:00 IST — Rollback initiated

### Rollback sequence

1. Freeze promotion.
2. Set canary traffic to 0%.
3. Route traffic back to the known-good version.
4. Stop new connections to the faulty canary.
5. Allow safe in-flight requests to drain.
6. Keep monitoring database and payment dependencies.
7. Scale/restart affected workloads only where required.
8. Verify recovery metrics.

The rollback is designed to be independent of the failed application deployment path wherever possible.

---

## T+6 minutes — 17:21:00 IST — Traffic restored

Traffic is routed to the previous healthy release.

Initial observations:

- HTTP 500 rate falling;
- new database connection requests recovering;
- payment gateway timeout rate falling;
- canary no longer receives customer traffic.

### Decision

Keep the failed release quarantined.

Do **not** resume deployment.

---

## T+8 minutes — 17:23:00 IST — Post-rollback verification

The following checks are executed.

### Application verification

- Kubernetes readiness probes: PASS
- Kubernetes liveness probes: PASS
- startup health: PASS
- application smoke tests: PASS
- API health endpoint: PASS

### Transaction verification

Synthetic payment flow:

```text
Create payment request
       |
       v
Authentication
       |
       v
Payment authorization
       |
       v
Payment gateway response
       |
       v
Database transaction
       |
       v
Customer-visible confirmation
```

Result: **PASS in simulation.**

### Infrastructure verification

- PostgreSQL connection pool: recovering/healthy
- CPU: below saturation threshold
- memory: below saturation threshold
- queue depth: stable
- payment timeout rate: back to baseline
- HTTP 5xx: below rollback threshold

---

## T+10 minutes — 17:25:00 IST — Service stabilized

The incident commander confirms that:

- customer traffic is no longer routed to the faulty release;
- key payment paths are functioning;
- error rates have returned to acceptable levels;
- database connections are stable;
- no further deployment is permitted.

The incident remains open for observation.

---

## T+15 minutes — 17:30:00 IST — Stabilization review

A short observation window is used to verify that metrics remain stable.

Checks:

- HTTP 5xx trend remains normal.
- p99 latency does not show regression.
- Payment gateway timeouts remain at baseline.
- PostgreSQL connection utilization remains healthy.
- No new CrashLoopBackOff/OOM events occur.
- Synthetic transactions continue to succeed.

### Decision

Declare the production service **recovered**.

Continue incident analysis and evidence preservation.

---

# 7. Root-Cause Analysis

## 7.1 Immediate technical cause

The simulated hotfix introduced behaviour that caused production degradation during canary execution.

The exact application defect is intentionally not specified by the assessment. Therefore, this document does **not** invent a specific code-level defect.

The observable chain is:

```text
Unsafe hotfix
     |
     v
Production canary
     |
     +--> HTTP 500 increase
     |
     +--> DB connection pool exhaustion
     |
     +--> Payment gateway timeouts
     |
     v
Automated detection
     |
     v
Rollback
```

## 7.2 Process/root cause

The most important root cause is:

> **The emergency hotfix bypassed the staging promotion control.**

The assessment explicitly requires emergency hotfixes to use an expedited path **without bypassing security and compliance gates**.

Therefore, the missing/bypassed control is primarily the **environment promotion/change-management gate**.

---

# 8. Five-Why Analysis

### Why 1 — Why did customers experience payment failures?

Because the new canary release generated severe application errors, database connection exhaustion, and payment gateway timeouts.

### Why 2 — Why did the faulty release reach production?

Because the critical hotfix was promoted to production without completing the normal staging validation.

### Why 3 — Why was staging bypassed?

Because the emergency path allowed the release process to circumvent the environment-promotion control.

### Why 4 — Why could the emergency path circumvent the control?

Because the promotion workflow did not technically enforce the rule that a hotfix may be expedited but must still satisfy mandatory gates.

### Why 5 — Why was the control not technically enforced?

The governance requirement existed conceptually, but the pipeline's authorization/policy layer did not make the staging/compliance path an immutable machine-enforced prerequisite for production promotion.

### Root cause

**Insufficiently enforced production-promotion policy for emergency changes.**

---

# 9. Did the Pipeline Design Prevent the Incident?

## Short answer

**Partially.**

### What the pipeline successfully did

- Canary deployment limited the blast radius.
- Prometheus-style monitoring detected abnormal behaviour.
- HTTP 500 threshold triggered rollback logic.
- Database connection-pool exhaustion was a defined immediate rollback trigger.
- Synthetic transaction monitoring exposed customer-facing payment degradation.
- Automated rollback reduced the time to recovery.
- Versioned and signed artefacts allowed identification of the deployed release.

### What it failed to prevent

The pipeline allowed the unsafe hotfix to reach production without completing staging validation.

The assessment explicitly warns that hotfixes must be **expedited, not bypassed**.

Therefore:

> **Detection and recovery controls worked, but the preventive promotion control failed.**

---

# 10. Missing/Weak Gate Analysis

| Control | Expected behaviour | Simulated result | Improvement |
|---|---|---|---|
| Branch protection | Prevent uncontrolled merge | Should be enforced | Verify mandatory review |
| Build/test gate | Tests must pass | Hotfix bypass path needs enforcement | Make mandatory |
| SAST | Security threshold | Must not be bypassable | Policy-controlled exception only |
| Dependency scan | No critical CVEs | Must not be bypassable | Immutable gate |
| DAST | No Critical/High OWASP findings | Must not be bypassable | Controlled emergency workflow |
| Policy/compliance | RBI/PCI/change controls | Emergency path must still pass mandatory controls | Enforce with OPA |
| Staging promotion | Required validation | **BYPASSED** | Make production promotion depend on signed staging evidence |
| Pre-prod approval | UAT/compliance/DB validation | **BYPASSED/NOT COMPLETED** | Require machine-verifiable promotion evidence |
| Canary verification | Monitor live behaviour | **WORKED** | Retain and strengthen |
| Rollback | Automated recovery | **WORKED** | Retain independent rollback path |

---

# 11. Corrective Pipeline Design

The emergency path should become:

```text
Emergency Hotfix
      |
      v
Emergency classification
      |
      v
Expedited CI
      |
      +--> Unit tests
      +--> SAST
      +--> Dependency scan
      +--> Container scan
      +--> Policy checks
      +--> Required security checks
      |
      v
Staging validation
      |
      v
Pre-production evidence
      |
      v
Dual approval
      |
      v
Canary
      |
      v
Automated verification
      |
   +--+--+
   |     |
 FAIL   PASS
   |     |
   v     v
Rollback Progressive rollout
```

### Mandatory principle

**No emergency path may directly promote an unvalidated artefact to production.**

The emergency process may reduce waiting time and use expedited approvals, but it must not remove mandatory security, compliance, testing, or provenance controls.

---

# 12. Action Items

| ID | Action | Priority | Owner | Target |
|---|---|---|---|---|
| INC-001 | Make staging evidence a hard prerequisite for production promotion | P0 | Platform Engineering | Immediate |
| INC-002 | Block direct production promotion from hotfix branches | P0 | DevOps | Immediate |
| INC-003 | Require signed promotion attestations for each environment | P0 | DevSecOps | 7 days |
| INC-004 | Add OPA/Kyverno rule preventing unapproved promotion | P0 | Platform Security | 7 days |
| INC-005 | Require dual approval for emergency production changes | P0 | Release Management | Immediate |
| INC-006 | Add automated payment synthetic transaction verification | P1 | SRE | 7 days |
| INC-007 | Add database connection-pool saturation alert to rollback controller | P1 | SRE | 3 days |
| INC-008 | Test rollback independently from the primary deployment path | P1 | Platform Engineering | 14 days |
| INC-009 | Conduct recurring incident/tabletop exercises | P2 | SRE + Compliance | Monthly |
| INC-010 | Archive incident evidence in immutable storage | P1 | Compliance + Platform | 7 days |

---

# 13. Evidence to Preserve

The following artefacts should be retained for audit and post-mortem purposes:

- Git commit SHA;
- pull request and approval records;
- emergency-change request;
- CI/CD pipeline run ID;
- build logs;
- test results;
- SAST report;
- dependency/CVE report;
- SBOM;
- container image digest;
- image-signing/provenance evidence;
- policy evaluation results;
- environment promotion records;
- ArgoCD deployment history;
- Istio routing changes;
- Prometheus alerts;
- Grafana snapshots;
- Kubernetes events;
- application logs;
- database metrics;
- payment gateway error metrics;
- rollback execution logs;
- incident communication timeline;
- post-rollback verification results.

---

# 14. Lessons Learned

### Lesson 1 — Canary is a containment mechanism, not a substitute for testing

Canary reduced the blast radius and exposed the defect before full rollout. It did not make bypassing staging acceptable.

### Lesson 2 — Emergency changes require stronger automation

A human saying "this is a critical hotfix" must not be enough to bypass a mandatory control.

### Lesson 3 — Rollback must be faster than diagnosis

The pipeline should restore service first and perform deep root-cause analysis after stability is achieved.

### Lesson 4 — Customer-level monitoring matters

Server health alone is insufficient. Payment synthetic transactions provide an end-to-end customer signal.

### Lesson 5 — Compliance must be executable

A documented rule is weaker than a machine-enforced policy that physically prevents an invalid production promotion.

---

# 15. Final Incident Outcome

**Incident status:** Resolved in simulation  
**Primary response:** Automated canary freeze + rollback  
**Primary failed preventive control:** Environment promotion/staging validation  
**Primary successful detective controls:** HTTP error monitoring, DB pool monitoring, downstream payment monitoring  
**Primary successful recovery control:** Automated rollback  
**Required follow-up:** Make emergency promotion controls technically non-bypassable

The target architecture therefore remains aligned with the assessment objective of rapid recovery while maintaining regulatory and change-management controls.

---

## 16. Assessment Traceability

This document directly addresses the Day 12 requirements:

- Friday 5 PM incident scenario;
- three simultaneous alerts;
- mapping alerts to pipeline controls;
- timestamped response;
- severity classification;
- communication;
- rollback;
- post-rollback verification;
- root-cause identification;
- missing/bypassed gate;
- lessons learned;
- pipeline improvements;
- evidence preservation.

The source assessment describes this exercise in **Part B, Section B5 (page 24)** and the Day 12 methodology in **Part D, Section D3 (pages 39–40)**.

---

## AI Assistance & Attribution

> **AI Assistance:** This document was developed with AI-assisted drafting and analysis. The final technical decisions, thresholds, architecture alignment, scenario interpretation, validation, and submission responsibility remain with the project author. The primary governing source for this deliverable is the NovaPay Zero-Downtime CI/CD Pipeline Assessment provided for this project.
