# NovaPay Digital Bank --- Incident Response Playbook

**Deliverable:** 7 --- Runbook & Incident Playbook\
**Audience:** SRE, Incident Commander, Engineering, Security,
Compliance, Management\
**Purpose:** Provide a deterministic response procedure for production
incidents while protecting availability, data integrity, customer trust
and auditability.

------------------------------------------------------------------------

## 1. Purpose

This playbook defines how NovaPay detects, classifies, contains,
recovers from, communicates and closes production incidents.

It is designed for use by an on-call engineer with minimal context.

Primary objectives:

1.  Protect customers and financial transactions.
2.  Restore service safely.
3.  Prevent uncontrolled deployment activity.
4.  Use the correct rollback path.
5.  Maintain an auditable incident record.
6.  Communicate according to severity.
7.  Produce corrective and preventive actions.

------------------------------------------------------------------------

# 2. Incident Severity Classification

  ------------------------------------------------------------------------
  Severity         Definition            Initial response Escalation path
  ---------------- ---------------- --------------------- ----------------
  **SEV-1**        Complete service           **\<5 min** CTO + CISO + VP
                   outage or                              Engineering
                   data-integrity                         
                   risk                                   

  **SEV-2**        Major feature             **\<15 min** VP Engineering +
                   degradation                            SRE Lead
                   affecting \>10%                        
                   users                                  

  **SEV-3**        Minor                     **\<1 hour** SRE On-call +
                   degradation;                           Tech Lead
                   workaround                             
                   exists                                 

  **SEV-4**        Cosmetic issue;  **Next business day** Assigned
                   no user impact                         engineer
  ------------------------------------------------------------------------

When uncertain between two severities, select the higher severity until
impact is understood.

------------------------------------------------------------------------

# 3. Immediate Safety Rules

During an active incident:

-   Do not continue a suspect deployment.
-   Freeze progressive rollout when a release may be involved.
-   Protect financial transaction integrity.
-   Do not expose customer-sensitive information in chat or tickets.
-   Do not make untracked production changes.
-   Record important decisions and timestamps.
-   Preserve logs, metrics, alerts and deployment evidence.
-   Use the rollback specification when automated rollback conditions
    are met.

------------------------------------------------------------------------

# 4. Seven-Step Incident Response Workflow

``` text
1. DETECT
     ↓
2. TRIAGE
     ↓
3. DECLARE
     ↓
4. CONTAIN
     ↓
5. RECOVER
     ↓
6. COMMUNICATE
     ↓
7. CLOSE + POSTMORTEM
```

------------------------------------------------------------------------

## Step 1 --- Detect

Detection sources include:

-   Prometheus.
-   Alertmanager.
-   Kubernetes events.
-   Application health checks.
-   Synthetic payment monitoring.
-   Customer reports.
-   Support escalation.
-   Security monitoring.
-   Compliance/audit findings.

Record:

-   Detection timestamp.
-   Alert name.
-   Service.
-   Environment.
-   Metric/value.
-   Threshold.
-   Deployment/release ID if known.

### Output

A traceable incident signal exists.

------------------------------------------------------------------------

# 6. Step 2 --- Triage

Determine:

-   What is failing?
-   Who is affected?
-   Is production affected?
-   Is a deployment correlated with the failure?
-   Is financial data at risk?
-   Is the failure infrastructure, application, database, security or
    downstream dependency related?
-   Is rollback required?

Correlate:

``` text
Alert
 ↓
Deployment timestamp
 ↓
Git SHA
 ↓
Image digest
 ↓
Canary/blue-green state
 ↓
Kubernetes events
 ↓
DB health
 ↓
Payment success
 ↓
Downstream dependency health
```

### Output

A preliminary cause and severity are established.

------------------------------------------------------------------------

# 7. Step 3 --- Declare

Create/update the incident record.

Required fields:

``` text
Incident ID:
Severity:
Incident Commander:
Technical Lead:
Start time:
Detection time:
Affected service:
Affected environment:
Release:
Git SHA:
Image digest:
Customer impact:
Current status:
```

Open the appropriate incident communication channel.

### Output

Incident ownership is explicit.

------------------------------------------------------------------------

# 8. Step 4 --- Contain

Containment depends on the incident.

### Suspect deployment

``` text
Freeze rollout
    ↓
Stop further promotion
    ↓
Rollback if trigger criteria met
```

### Application failure

-   Remove unhealthy traffic where appropriate.
-   Restore the last known-good release.
-   Scale only when scaling is a safe mitigation.
-   Protect dependencies.

### Database risk

-   Stop unsafe migration activity.
-   Preserve data integrity.
-   Engage DBA.
-   Do not blindly reverse financial data changes.

### Security incident

-   Engage Security/CISO path.
-   Preserve evidence.
-   Restrict access according to approved incident procedures.

------------------------------------------------------------------------

# 9. Step 5 --- Recover

Recovery must be verified, not assumed.

For deployment-related incidents:

``` text
Freeze
 ↓
Rollback
 ↓
Health checks
 ↓
Smoke tests
 ↓
Synthetic payment
 ↓
Metric comparison
 ↓
Customer impact assessment
```

Verify:

-   5xx recovery.
-   p99 recovery.
-   Payment success recovery.
-   DB health.
-   Redis/dependency health where applicable.
-   CPU/memory stability.
-   Pod restart stability.
-   No new critical alerts.

### Recovery decision

``` text
Service healthy?
       |
   +---+---+
   |       |
  YES      NO
   |       |
   ↓       ↓
Proceed    Escalate
to closure and continue
```

------------------------------------------------------------------------

# 10. Step 6 --- Communicate

Communication must be appropriate for the severity and audience.

### Internal technical communication

Include:

-   What happened.
-   Current impact.
-   What is being done.
-   Current release.
-   Rollback status.
-   Next update time.

### Business communication

Focus on:

-   Customer impact.
-   Business services affected.
-   Current mitigation.
-   Expected next update.

### Regulatory/compliance communication

Use only approved channels and provide verified facts:

-   Incident classification.
-   Time detected.
-   Affected service.
-   Material impact where established.
-   Containment/recovery status.
-   Evidence and incident reference.

Do not speculate.

------------------------------------------------------------------------

# 11. Step 7 --- Close and Postmortem

Close only after:

-   Service has recovered.
-   Monitoring is stable.
-   Customer impact is assessed.
-   Incident record is complete.
-   Evidence is archived.
-   Required stakeholders are notified.
-   Follow-up actions have owners.

Then create a postmortem covering:

``` text
Timeline
 ↓
Root cause
 ↓
Contributing factors
 ↓
Why controls did not prevent/detect earlier
 ↓
Corrective actions
 ↓
Preventive controls
```

------------------------------------------------------------------------

# 12. Deployment/Rollback Incident Procedure

For a release-related incident:

``` text
Prometheus / Alertmanager
          ↓
       Alert
          ↓
      Correlate
          ↓
       Freeze
          ↓
     Rollback
          ↓
       Verify
          ↓
       Notify
          ↓
      Incident
          ↓
     Postmortem
```

### Category A

Immediate rollback target: **\<60 seconds**.

Examples:

-   5xx \>5% for 60 seconds.
-   Three consecutive health failures.
-   OOMKill.
-   CrashLoopBackOff.
-   DB connection-pool exhaustion.
-   Critical synthetic payment failure.

### Category B

Escalated target: **\<15 minutes**.

Examples:

-   p99 \>2× baseline for 5 minutes.
-   Error-budget burn \>10× normal for 10 minutes.
-   Transaction success \>2% below baseline.
-   CPU \>90% for 5 minutes.
-   Memory \>85% for 5 minutes.

### Category C

Manual decision:

-   Gradual degradation below automated thresholds.
-   Customer support reports.
-   Retroactive compliance failure.
-   Downstream dependency correlation.

------------------------------------------------------------------------

# 13. Incident Command Roles

  -----------------------------------------------------------------------
  Role                                Responsibility
  ----------------------------------- -----------------------------------
  Incident Commander                  Coordinates incident and decisions

  Technical Lead                      Directs technical
                                      diagnosis/recovery

  SRE                                 Executes operational actions and
                                      monitoring

  Communications Lead                 Sends approved updates

  Release Manager                     Coordinates release/change
                                      information

  DBA                                 Handles database analysis/recovery

  Security/CISO representative        Handles security/data-risk cases

  Compliance representative           Handles regulatory
                                      evidence/notification requirements
  -----------------------------------------------------------------------

One person should not silently perform all roles during a major
incident.

------------------------------------------------------------------------

# 14. Evidence Requirements

Preserve:

-   Alert payload.
-   Alert timestamp.
-   Metric values.
-   Deployment ID.
-   Git SHA.
-   Image digest.
-   Argo CD revision.
-   Helm metadata.
-   Istio routing state.
-   Kubernetes events.
-   Pod status/restarts.
-   DB health.
-   Payment success.
-   Downstream dependency status.
-   Rollback event.
-   Verification results.
-   Customer impact.
-   Communications.
-   Approvals/escalations.
-   Final incident status.

Store artifacts under:

``` text
evidence/
├── screenshots/
└── test-results/
```

------------------------------------------------------------------------

# 15. Customer Impact Assessment

Assess:

-   Number/percentage of affected users.
-   Failed requests.
-   Failed payment attempts.
-   Delayed payments.
-   Duplicate-payment risk.
-   Data-integrity risk.
-   Duration.
-   Geographic/tenant scope.
-   Reconciliation requirement.

Financial recovery must distinguish application rollback from financial
transaction recovery.

------------------------------------------------------------------------

# 16. Incident Status Definitions

  Status       Meaning
  ------------ --------------------------------------------
  DETECTED     Alert/report received
  TRIAGING     Scope and cause being assessed
  DECLARED     Incident formally opened
  CONTAINED    Impact is no longer increasing
  RECOVERING   Restoration in progress
  MONITORING   Service restored; stability being verified
  RESOLVED     Service stable and impact understood
  CLOSED       Evidence and follow-up actions complete

------------------------------------------------------------------------

# 17. Escalation Rules

### SEV-1

Escalate immediately to:

``` text
CTO
CISO
VP Engineering
```

### SEV-2

Escalate to:

``` text
VP Engineering
SRE Lead
```

### SEV-3

Escalate to:

``` text
SRE On-call
Tech Lead
```

### SEV-4

Assign to:

``` text
Responsible engineer
```

------------------------------------------------------------------------

# 18. Friday 5 PM Simulation Mapping

The assessment's incident simulation contains three simultaneous alerts:

-   HTTP 500 error rate = 12%, threshold 5%.
-   PostgreSQL connection pool exhaustion.
-   Payment gateway timeout rate = 35%.

These signals must be correlated rather than treated as isolated alerts.

Recommended response:

``` text
T+0
Alert fires
 ↓
T+30s
Triage + severity classification
 ↓
T+2m
Communication
 ↓
T+5m
Rollback/containment
 ↓
Recovery verification
 ↓
Incident evidence
 ↓
Postmortem
```

The scenario should be executed as a simulation with real timestamps and
evidence rather than represented as completed production activity.

------------------------------------------------------------------------

# 19. Quick Incident Decision Card

``` text
Is production affected?
NO → classify and assign
YES → continue

Is there data/financial integrity risk?
YES → SEV-1 path + immediate escalation

Is a deployment correlated?
YES → FREEZE rollout

Category A trigger?
YES → immediate rollback

Category B trigger?
YES → escalate and act within 15 min policy

Category C?
YES → manual assessment

Recovered?
NO → escalate

Recovered?
YES → monitor → communicate → close → postmortem
```

------------------------------------------------------------------------

## 20. Related Documents

-   `runbooks/deployment-runbook.md`
-   `runbooks/communication-templates.md`
-   `runbooks/postmortem-template.md`
-   `docs/06-rollback-specification/`
-   `pipeline/monitoring/`
-   `evidence/`

## AI Assistance & Attribution

> **AI Assistance:** This document was developed with AI-assisted drafting and analysis. The final technical decisions, thresholds, architecture alignment, implementation details, validation, and submission responsibility remain with the project author. The primary governing source for this deliverable is the NovaPay Zero-Downtime CI/CD Pipeline Assessment provided for this project.
