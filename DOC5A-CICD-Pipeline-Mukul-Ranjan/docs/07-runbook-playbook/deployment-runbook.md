# NovaPay Digital Bank --- Production Deployment Runbook

**Deliverable:** 7 --- Runbook & Incident Playbook\
**Document:** Production Deployment Runbook\
**Audience:** Release Manager, SRE, SRE Lead, Tech Lead, QA, DBA,
Compliance\
**Purpose:** Provide an on-call engineer with a deterministic,
evidence-driven procedure for a zero-downtime production deployment.

------------------------------------------------------------------------

## 1. Purpose

This runbook defines the controlled procedure for promoting an approved
NovaPay release to production.

The runbook is designed around:

-   Zero planned downtime.
-   Same artifact, different configuration.
-   Segregation of duties.
-   Immutable artifact verification.
-   Mandatory security and compliance gates.
-   Blue-green deployment as the primary strategy.
-   Canary deployment as the progressive-delivery alternative.
-   Automated rollback for defined production failure conditions.
-   Evidence collection for every material decision.

The production deployment must not bypass mandatory gates or approvals.

------------------------------------------------------------------------

## 2. Scope

This procedure covers:

1.  Pre-production readiness.
2.  Production approval.
3.  Artifact and configuration verification.
4.  Deployment execution.
5.  Progressive traffic management.
6.  Health and SLO verification.
7.  Rollback decision-making.
8.  Post-deployment evidence and closure.

### Environment path

``` text
DEV
  ↓
STAGING
  ↓
PRE-PROD
  ↓
PRODUCTION
```

The same application artifact/image is promoted through environments.
Environment-specific differences are configuration only.

------------------------------------------------------------------------

## 3. Roles and Responsibilities

  -----------------------------------------------------------------------
  Role                                Production responsibility
  ----------------------------------- -----------------------------------
  Release Manager                     Owns release/change approval and
                                      production coordination

  SRE Lead                            Production approval and operational
                                      readiness

  SRE                                 Executes/observes deployment and
                                      verifies health

  Tech Lead                           Technical review and release
                                      readiness

  QA                                  Test/UAT evidence and verification

  DBA                                 Database migration readiness and
                                      production DB support

  Compliance                          Regulatory evidence and gate
                                      verification

  Developer                           Release support; no uncontrolled
                                      direct production deployment
  -----------------------------------------------------------------------

Production requires independent approval from the **Release Manager AND
SRE Lead**.

------------------------------------------------------------------------

# 4. Pre-Deployment Checklist

All eight items must be PASS before production deployment.

  ----------------------------------------------------------------------------------------------------------
  \#             Check                       PASS condition  Evidence required                FAIL action
  -------------- --------------------------- --------------- -------------------------------- --------------
  1              Release approval            Release         Approval/change record           Stop
                                             Manager + SRE                                    deployment
                                             Lead approved                                    

  2              Artifact verification       Correct         Image digest/signature evidence  Stop;
                                             immutable image                                  investigate
                                             digest, signed                                   artifact
                                             artifact and                                     
                                             approved                                         
                                             version                                          

  3              Security verification       Required        SAST/DAST/dependency/container   Remediate and
                                             security gates  scan/SBOM results                rerun
                                             passed; no                                       
                                             blocking                                         
                                             findings                                         

  4              Compliance verification     Mandatory       Compliance gate results, policy  Hard block;
                                             RBI/PCI-DSS     evidence                         exception
                                             mapped controls                                  process only
                                             and policy                                       
                                             gates PASS                                       

  5              Database verification       Migration       Migration test result, DB        Stop;
                                             tested and      readiness evidence               remediate
                                             compatible with                                  migration
                                             running version                                  

  6              Environment/configuration   Production      Helm/config diff,                Correct
                 verification                values/config   secret-management evidence       config; never
                                             are approved;                                    commit secrets
                                             no plaintext                                     
                                             secrets                                          

  7              Monitoring/rollback         Prometheus,     Monitoring/alerting evidence     Stop until
                 verification                Alertmanager,                                    monitoring is
                                             probes and                                       operational
                                             rollback                                         
                                             controls ready                                   

  8              Change window/on-call       Approved        Change ticket/calendar/on-call   Reschedule or
                 verification                window, not     acknowledgement                  obtain
                                             blackout/peak                                    approved
                                             period; on-call                                  change path
                                             engineer                                         
                                             briefed                                          
  ----------------------------------------------------------------------------------------------------------

### Checklist decision

``` text
All 8 PASS?
   |
   +-- NO --> BLOCK DEPLOYMENT
   |           ↓
   |        Remediate
   |           ↓
   |        Re-run failed check
   |
   +-- YES --> Continue to production deployment
```

------------------------------------------------------------------------

# 5. Step 1 --- Confirm Production Approvals

Verify:

-   Product Owner UAT sign-off.
-   Regulatory compliance gates passed.
-   RBI + PCI-DSS mapping verified.
-   Database migration tested with production-scale data.
-   Runbook reviewed and signed off by SRE Lead.
-   CAB approval OR approved pre-authorised change category.
-   Release Manager approval.
-   SRE Lead approval.
-   Deployment window approved.
-   On-call engineer confirmed and briefed.

### Decision tree

``` text
Required approvals complete?
       |
   +---+---+
   |       |
  YES      NO
   |       |
   ↓       ↓
Continue   BLOCK
```

**Expected outcome:** An auditable production change is approved.

**Evidence:** Change record, approvals, UAT result, compliance evidence.

------------------------------------------------------------------------

# 6. Step 2 --- Verify Immutable Artifact

Confirm:

-   Repository/commit is the approved release.
-   SemVer release/tag exists.
-   Image digest matches the approved digest.
-   Image signature is valid.
-   Artifact came from the approved registry.
-   SBOM is archived.
-   No artifact substitution occurred between environments.

### Decision tree

``` text
Digest + signature + version match?
       |
   +---+---+
   |       |
  YES      NO
   |       |
   ↓       ↓
Continue   STOP
           ↓
        Investigate
```

**Expected outcome:** The exact approved artifact is selected.

**Evidence:** Image digest, signature verification, release metadata,
SBOM.

------------------------------------------------------------------------

# 7. Step 3 --- Verify Production Configuration

Check:

-   `values-production.yaml`.
-   Base → environment → service configuration hierarchy.
-   Feature flags.
-   Resource requests/limits.
-   Replica count.
-   Probes.
-   Service/Ingress configuration.
-   Istio routing configuration.
-   Secret references.

Secrets must come from the approved secret-management system. Do not
store plaintext secrets in Git, Helm values, Kubernetes manifests,
Dockerfiles or source code.

### Decision tree

``` text
Configuration approved and secrets protected?
       |
   +---+---+
   |       |
  YES      NO
   |       |
   ↓       ↓
Continue   BLOCK
```

**Expected outcome:** Production configuration is correct and contains
no uncontrolled secrets.

**Evidence:** Sanitized configuration diff, Helm render/validation
result, secret-reference evidence.

------------------------------------------------------------------------

# 8. Step 4 --- Verify Database Migration

Use the zero-downtime migration pattern:

``` text
EXPAND
  ↓
MIGRATE
  ↓
CONTRACT
```

Rules:

-   Expand changes must remain backward compatible.
-   Migration must be tested before production.
-   Data changes must be idempotent where applicable.
-   Large migrations must be controlled/throttled.
-   Contract changes are separated from the initial release.
-   Abort if the defined database performance safety threshold is
    exceeded.

### Decision tree

``` text
Migration compatible and verified?
       |
   +---+---+
   |       |
  YES      NO
   |       |
   ↓       ↓
Continue   BLOCK
```

**Expected outcome:** Database remains compatible with both stable and
candidate application versions.

**Evidence:** Migration test results, schema/version record, performance
verification.

------------------------------------------------------------------------

# 9. Step 5 --- Verify Monitoring and Rollback Readiness

Confirm:

-   Kubernetes readiness/liveness/startup probes.
-   Prometheus metrics.
-   Alertmanager routes.
-   Rollback alert rules.
-   Synthetic payment monitoring.
-   Error-rate monitoring.
-   p99 latency monitoring.
-   DB connection-pool monitoring.
-   CPU and memory monitoring.
-   Rollback controller/webhook is available independently of the
    primary deployment path.

### Decision tree

``` text
Monitoring + rollback controls healthy?
       |
   +---+---+
   |       |
  YES      NO
   |       |
   ↓       ↓
Continue   BLOCK
```

**Expected outcome:** A failed release can be detected and recovered
without depending on the failed deployment path.

**Evidence:** Alert rules, Alertmanager configuration, monitoring
status, readiness evidence.

------------------------------------------------------------------------

# 10. Step 6 --- Deploy Candidate

Primary strategy: **Blue-Green deployment**.

``` text
              Istio
                |
        +-------+-------+
        |               |
      BLUE            GREEN
     Stable          Candidate
      100%              0%
```

Procedure:

1.  Deploy candidate/Green.
2.  Do not immediately send production traffic to it.
3.  Wait for Kubernetes readiness.
4.  Confirm startup/liveness/readiness probes.
5.  Run smoke tests.
6.  Run synthetic payment.
7.  Compare candidate metrics with stable baseline.
8.  Confirm no rollback trigger.
9.  Prepare traffic switch.

### Decision tree

``` text
Candidate healthy?
       |
   +---+---+
   |       |
  YES      NO
   |       |
   ↓       ↓
Verify     Freeze
and switch Rollback/repair
```

**Expected outcome:** Candidate is running and healthy while stable
remains available.

**Evidence:** Deployment status, pod readiness, Argo CD sync, image
digest, Helm metadata.

------------------------------------------------------------------------

# 11. Step 7 --- Progressive Traffic Switch

For blue-green:

``` text
Before:
Stable 100% / Candidate 0%

After approved switch:
Stable 0% / Candidate 100%
```

For canary alternative:

``` text
1–2%
 ↓
5–10%
 ↓
25–50%
 ↓
100%
```

At each canary phase:

``` text
Measure
  ↓
Gate
 ├── PASS → Next phase
 └── FAIL → Freeze → Stable 100% → Verify
```

Monitor:

-   HTTP 5xx.
-   p99 latency.
-   Payment success.
-   Health/readiness.
-   CPU.
-   Memory.
-   Pod restarts.
-   DB health.
-   Downstream dependency health.

------------------------------------------------------------------------

# 12. Rollback Triggers During Deployment

### Immediate rollback / Category A

Target: **\<60 seconds**

Trigger examples:

-   HTTP 5xx \>5% for 60 seconds.
-   Three consecutive health failures.
-   OOMKill detected.
-   CrashLoopBackOff detected.
-   Database connection-pool exhaustion.
-   Critical synthetic payment failure.

### Escalated / Category B

Target: **\<15 minutes**

Trigger examples:

-   p99 latency \>2× baseline for 5 minutes.
-   Error-budget burn \>10× normal for 10 minutes.
-   Transaction success \>2% below baseline.
-   CPU \>90% for 5 minutes.
-   Memory \>85% for 5 minutes.

### Manual / Category C

Examples:

-   Gradual degradation below automated thresholds.
-   Customer-support reports.
-   Retroactive compliance failure.
-   Downstream dependency correlation requiring human judgment.

------------------------------------------------------------------------

# 13. Step 8 --- Freeze and Rollback Decision

If a blocking failure occurs:

``` text
Detect
  ↓
Correlate with release
  ↓
FREEZE
  ↓
Rollback decision
```

Do not continue promotion while a rollback trigger is active.

### Blue-green rollback

``` text
Candidate 100%
     ↓
Failure
     ↓
Stable 100%
Candidate 0%
```

### Canary rollback

``` text
Canary
  ↓
0%
  ↓
Stable
  ↓
100%
```

### Decision

``` text
Automatic rollback trigger?
       |
   +---+---+
   |       |
  YES      NO
   |       |
   ↓       ↓
Rollback   Manual assessment
```

Use the independent rollback path defined by the rollback specification.

------------------------------------------------------------------------

# 14. Step 9 --- Post-Deployment Verification

Verification must include:

### Application health

-   Startup probes PASS.
-   Readiness probes PASS.
-   Liveness probes PASS.
-   Expected replica count available.
-   No CrashLoopBackOff.
-   No new OOMKill.

### Smoke tests

``` text
Health
Readiness
Authentication
Account lookup
Payment initiation
Payment status
Transaction history
Synthetic payment
```

### Metrics

Compare candidate/stable and pre/post deployment:

  Metric              Expected outcome
  ------------------- --------------------------------------------------------
  HTTP 5xx            Within approved threshold / returns to baseline
  p99 latency         Within approved threshold / no sustained \>2× baseline
  Payment success     No material degradation
  CPU                 Within operational threshold
  Memory              Within operational threshold
  DB errors           No abnormal increase
  Pod restarts        Stable/no unexpected spike
  DB pool             Not exhausted
  Synthetic payment   Successful

### Customer impact assessment

Assess:

-   Failed requests.
-   Failed payment attempts.
-   Affected customers where measurable.
-   Duplicate-payment risk.
-   Delayed-payment risk.
-   Reconciliation requirements.
-   Duration and scope of impact.
-   Geographic/tenant impact where applicable.

Important:

``` text
Application rollback
       ≠
Financial transaction rollback
```

Financial transaction recovery must use reconciliation and
transaction-safety controls rather than blindly reverting financial
records.

------------------------------------------------------------------------

# 15. Step 10 --- Close the Deployment

When verification passes:

1.  Confirm traffic state.
2.  Confirm candidate is the intended production release.
3.  Record final image digest.
4.  Record Argo CD revision.
5.  Record Helm release metadata.
6.  Record routing state.
7.  Record monitoring results.
8.  Update change record.
9.  Archive evidence.
10. Notify stakeholders.

### Successful deployment

``` text
Deploy
 ↓
Verify
 ↓
Metrics PASS
 ↓
Smoke PASS
 ↓
Synthetic payment PASS
 ↓
Customer impact acceptable
 ↓
CLOSE CHANGE
```

------------------------------------------------------------------------

# 16. Deployment Evidence Checklist

Store evidence in:

``` text
evidence/
├── screenshots/
└── test-results/
```

Capture only genuine execution evidence.

Recommended evidence:

-   Production approval record.
-   Artifact/image digest.
-   Signature verification.
-   SBOM.
-   Security gate results.
-   Compliance gate results.
-   DB migration test.
-   Helm configuration/render.
-   Argo CD sync.
-   Kubernetes readiness.
-   Istio traffic state.
-   Prometheus metrics.
-   Alertmanager status/routing.
-   Smoke-test results.
-   Synthetic payment result.
-   Rollback event if rollback occurred.
-   Final verification.
-   Customer impact assessment.

Do not fabricate screenshots or test results.

------------------------------------------------------------------------

# 17. Emergency Deployment

Emergency deployment still requires traceability.

Procedure:

``` text
Incident
  ↓
Emergency change classification
  ↓
Risk assessment
  ↓
Required approvals
  ↓
Artifact/security verification
  ↓
Controlled deployment
  ↓
Verification
  ↓
Evidence
  ↓
Retrospective review
```

An emergency process must not become an uncontrolled bypass of mandatory
security, compliance or audit controls.

------------------------------------------------------------------------

# 18. Quick 3 AM Decision Card

``` text
1. Is the change approved?
   NO → STOP

2. Is the artifact digest correct?
   NO → STOP

3. Are security/compliance gates PASS?
   NO → STOP

4. Is DB migration safe?
   NO → STOP

5. Is monitoring and rollback ready?
   NO → STOP

6. Is candidate healthy?
   NO → FREEZE / ROLLBACK

7. Are smoke + synthetic payment tests PASS?
   NO → ROLLBACK

8. Are 5xx, p99, payment success and resource metrics healthy?
   NO → FREEZE / ROLLBACK

9. Is customer impact acceptable?
   NO → ROLLBACK / INCIDENT

10. Everything PASS?
    YES → COMPLETE DEPLOYMENT + ARCHIVE EVIDENCE
```

------------------------------------------------------------------------

## 19. Related Project Documents

-   `docs/01-pipeline-architecture/`
-   `docs/02-deployment-strategies/`
-   `docs/03-compliance-gates/`
-   `docs/04-database-migration/`
-   `docs/05-environment-promotion/`
-   `docs/06-rollback-specification/`
-   `pipeline/helm/`
-   `pipeline/monitoring/`
-   `runbooks/incident-playbook.md`
-   `runbooks/communication-templates.md`
-   `runbooks/postmortem-template.md`
