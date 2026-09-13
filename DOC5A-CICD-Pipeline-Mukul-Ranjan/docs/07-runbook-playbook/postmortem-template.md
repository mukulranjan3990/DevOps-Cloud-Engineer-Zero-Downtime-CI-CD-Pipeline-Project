# NovaPay Digital Bank --- Incident Postmortem Template

**Document type:** Incident Postmortem\
**Purpose:** Create a consistent, evidence-based record of production
incidents, their causes, impact, recovery and corrective actions.

> Complete this document after the incident. Do not invent facts. Every
> timestamp, metric and action should be supported by available
> evidence.

------------------------------------------------------------------------

# 1. Incident Summary

  Field                    Value
  ------------------------ -----------------------------
  Incident ID              `<incident-id>`
  Severity                 `<SEV-1/2/3/4>`
  Service                  `<service>`
  Environment              `production`
  Incident Commander       `<name>`
  Technical Lead           `<name>`
  Detection time           `<timestamp>`
  Start time               `<timestamp>`
  Recovery time            `<timestamp>`
  End time                 `<timestamp>`
  Duration                 `<duration>`
  Release                  `<release>`
  Git SHA                  `<git-sha>`
  Candidate image digest   `<digest>`
  Stable image digest      `<digest>`
  Deployment strategy      `<blue-green/canary/other>`
  Rollback                 `<yes/no>`
  Customer impact          `<summary>`

------------------------------------------------------------------------

# 2. Executive Summary

## What happened?

`<Short factual description>`

## Why did it matter?

`<Customer/business/availability/data-integrity impact>`

## How was service restored?

`<Recovery or rollback summary>`

## Current status

`<Resolved / Monitoring / Follow-up required>`

------------------------------------------------------------------------

# 3. Customer Impact

Record measurable impact.

  Measure                   Result
  ------------------------- ----------------
  Affected users            `<number/%>`
  Failed requests           `<number/%>`
  Failed payment attempts   `<number>`
  Delayed payments          `<number>`
  Duplicate-payment risk    `<assessment>`
  Data-integrity risk       `<assessment>`
  Duration                  `<duration>`
  Geographic/tenant scope   `<scope>`

### Financial transaction assessment

``` text
Application rollback:
<status>

Financial transaction reconciliation:
<status>

Duplicate transaction assessment:
<status>

Customer remediation:
<status>
```

Do not equate application rollback with financial transaction rollback.

------------------------------------------------------------------------

# 4. Detection

## Detection source

``` text
Prometheus
Alertmanager
Kubernetes
Synthetic monitoring
Customer support
Security monitoring
Other: <value>
```

## Alert details

``` text
Alert:
<alert name>

Metric:
<metric>

Observed value:
<value>

Threshold:
<threshold>

First detected:
<timestamp>
```

## Detection effectiveness

-   Was the incident detected automatically?
-   How quickly?
-   Was the correct severity generated?
-   Was the alert actionable?

------------------------------------------------------------------------

# 5. Timeline

Use exact timestamps where available.

  Time   Event                  Actor/System              Evidence
  ------ ---------------------- ------------------------- ---------------
  T+0    Alert fired            Prometheus/Alertmanager   `<reference>`
  T+     Triage started         `<role>`                  `<reference>`
  T+     Severity declared      `<role>`                  `<reference>`
  T+     Communication sent     `<role>`                  `<reference>`
  T+     Rollout frozen         `<role/system>`           `<reference>`
  T+     Rollback initiated     `<system>`                `<reference>`
  T+     Verification started   `<role>`                  `<reference>`
  T+     Service recovered      `<role/system>`           `<reference>`
  T+     Incident resolved      `<role>`                  `<reference>`

Add rows until the incident is fully closed.

------------------------------------------------------------------------

# 6. Incident Classification

## Severity

`<SEV-1/SEV-2/SEV-3/SEV-4>`

## Reason

`<Why this severity matched the incident>`

## Escalation

``` text
SEV-1 → CTO + CISO + VP Engineering
SEV-2 → VP Engineering + SRE Lead
SEV-3 → SRE On-call + Tech Lead
SEV-4 → Assigned Engineer
```

------------------------------------------------------------------------

# 7. Technical Impact

Affected components:

``` text
Application:
<component>

Kubernetes:
<component>

Ingress/Istio:
<component>

Database:
<component>

Cache:
<component>

Payment gateway:
<component>

Other dependencies:
<component>
```

------------------------------------------------------------------------

# 8. Root Cause Analysis

## Primary root cause

`<Verified root cause>`

## Contributing factors

1.  `<factor>`
2.  `<factor>`
3.  `<factor>`

## Trigger

`<What initiated the failure>`

## Why did the failure propagate?

`<Explanation>`

## Why did monitoring detect it?

`<Explanation>`

## Why did the pipeline controls not prevent it?

`<Explanation>`

------------------------------------------------------------------------

# 9. Five Whys

### Why 1?

`<answer>`

### Why 2?

`<answer>`

### Why 3?

`<answer>`

### Why 4?

`<answer>`

### Why 5?

`<answer>`

### Root cause identified

`<final root cause>`

------------------------------------------------------------------------

# 10. Deployment Correlation

If a deployment occurred near the incident:

  Field               Value
  ------------------- ----------------
  Deployment ID       `<id>`
  Release             `<release>`
  Git SHA             `<sha>`
  Image digest        `<digest>`
  Deployment start    `<timestamp>`
  Failure detected    `<timestamp>`
  Canary percentage   `<percentage>`
  Blue/green state    `<state>`
  Argo CD revision    `<revision>`
  Istio routing       `<state>`

### Correlation conclusion

``` text
Release likely causal
Release unlikely causal
Insufficient evidence
Downstream dependency causal
Infrastructure causal
Other: <value>
```

Explain the evidence supporting the conclusion.

------------------------------------------------------------------------

# 11. Rollback Analysis

## Trigger category

``` text
Category A — Immediate
Category B — Escalated
Category C — Manual
Not applicable
```

## Trigger

`<alert/condition>`

## Threshold

`<threshold>`

## Observed value

`<value>`

## Rollback time

`<timestamp>`

## Stable release

`<release/digest>`

## Rollback method

``` text
Blue-green traffic reversal
Canary traffic reversal
Feature flag
Other
```

## Rollback verification

  Verification        Result
  ------------------- ---------------
  Health              `<PASS/FAIL>`
  Readiness           `<PASS/FAIL>`
  Smoke tests         `<PASS/FAIL>`
  Synthetic payment   `<PASS/FAIL>`
  HTTP 5xx            `<result>`
  p99 latency         `<result>`
  Payment success     `<result>`
  Database health     `<result>`
  CPU                 `<result>`
  Memory              `<result>`

------------------------------------------------------------------------

# 12. What Went Well?

1.  `<item>`
2.  `<item>`
3.  `<item>`

Examples may include:

-   Fast automated detection.
-   Correct severity classification.
-   Independent rollback path.
-   Successful traffic reversal.
-   Effective communication.
-   Complete evidence capture.

------------------------------------------------------------------------

# 13. What Went Poorly?

1.  `<item>`
2.  `<item>`
3.  `<item>`

Examples:

-   Detection delay.
-   Missing alert.
-   Incorrect threshold.
-   Approval gap.
-   Configuration error.
-   Insufficient test coverage.
-   Communication delay.

------------------------------------------------------------------------

# 14. Where Did Controls Fail?

Evaluate each relevant control:

  Control            Expected behavior           Actual behavior   Gap
  ------------------ --------------------------- ----------------- ---------
  Unit tests         Block bad change            `<result>`        `<gap>`
  Security gates     Block unsafe artifact       `<result>`        `<gap>`
  Compliance gates   Block policy violation      `<result>`        `<gap>`
  Deployment gate    Block unhealthy release     `<result>`        `<gap>`
  Health probes      Detect unhealthy pods       `<result>`        `<gap>`
  Prometheus         Detect SLO/metric failure   `<result>`        `<gap>`
  Alertmanager       Route alert                 `<result>`        `<gap>`
  Rollback           Restore stable version      `<result>`        `<gap>`

------------------------------------------------------------------------

# 15. Corrective Actions

Actions that directly fix the incident.

  Action       Owner       Priority       Due date   Status
  ------------ ----------- -------------- ---------- --------
  `<action>`   `<owner>`   High/Med/Low   `<date>`   Open
  `<action>`   `<owner>`   High/Med/Low   `<date>`   Open
  `<action>`   `<owner>`   High/Med/Low   `<date>`   Open

------------------------------------------------------------------------

# 16. Preventive Actions

Actions that reduce the chance or impact of recurrence.

Examples:

-   Add or strengthen a pipeline gate.
-   Add a regression test.
-   Improve alert threshold.
-   Improve canary analysis.
-   Add dependency health correlation.
-   Improve database migration verification.
-   Improve approval controls.
-   Improve runbook instructions.
-   Add rollback testing.
-   Improve observability.

  Preventive action   Owner       Due date   Success criteria   Status
  ------------------- ----------- ---------- ------------------ --------
  `<action>`          `<owner>`   `<date>`   `<criteria>`       Open
  `<action>`          `<owner>`   `<date>`   `<criteria>`       Open

------------------------------------------------------------------------

# 17. Communication Review

  Communication             Required?    Sent at    Audience       Evidence
  ------------------------- ------------ ---------- -------------- ----------
  Initial acknowledgement   Yes          `<time>`   Internal       `<ref>`
  SEV escalation            `<yes/no>`   `<time>`   Leadership     `<ref>`
  External status           `<yes/no>`   `<time>`   Customers      `<ref>`
  Regular update            `<yes/no>`   `<time>`   Stakeholders   `<ref>`
  Resolution notice         Yes          `<time>`   Stakeholders   `<ref>`

Assess:

-   Was communication timely?
-   Was the correct audience reached?
-   Were statements factual?
-   Was sensitive information protected?

------------------------------------------------------------------------

# 18. Evidence Register

Store references to genuine evidence.

  Evidence                     Location/reference   Verified by
  ---------------------------- -------------------- -------------
  Alert payload                `<reference>`        `<name>`
  Prometheus metrics           `<reference>`        `<name>`
  Alertmanager event           `<reference>`        `<name>`
  Kubernetes events            `<reference>`        `<name>`
  Argo CD revision             `<reference>`        `<name>`
  Image digest                 `<reference>`        `<name>`
  Routing state                `<reference>`        `<name>`
  Smoke tests                  `<reference>`        `<name>`
  Synthetic payment            `<reference>`        `<name>`
  Rollback event               `<reference>`        `<name>`
  Communication records        `<reference>`        `<name>`
  Customer impact assessment   `<reference>`        `<name>`

Recommended repository locations:

``` text
evidence/
├── screenshots/
└── test-results/
```

------------------------------------------------------------------------

# 19. Lessons Learned

## Technical

`<lesson>`

## Process

`<lesson>`

## Monitoring

`<lesson>`

## Security/compliance

`<lesson>`

## Incident response

`<lesson>`

------------------------------------------------------------------------

# 20. Pipeline Improvements

Identify which project deliverable must change.

  ---------------------------------------------------------------------------------------------------
  Improvement       Deliverable/component                         Owner             Due
  ----------------- --------------------------------------------- ----------------- -----------------
  `<improvement>`   `<pipeline/rollback/monitoring/compliance>`   `<owner>`         `<date>`

  `<improvement>`   `<component>`                                 `<owner>`         `<date>`
  ---------------------------------------------------------------------------------------------------

------------------------------------------------------------------------

# 21. Final Incident Status

``` text
[ ] Resolved
[ ] Monitoring
[ ] Follow-up actions open
[ ] Customer remediation open
[ ] Compliance review open
[ ] Security review open
```

### Final statement

`<Factual final status>`

------------------------------------------------------------------------

# 22. Approvals

  Role                           Name       Approval          Date
  ------------------------------ ---------- ----------------- ----------
  Incident Commander             `<name>`   `<approved>`      `<date>`
  Technical Lead                 `<name>`   `<approved>`      `<date>`
  SRE Lead                       `<name>`   `<approved>`      `<date>`
  Compliance                     `<name>`   `<if required>`   `<date>`
  Security/CISO representative   `<name>`   `<if required>`   `<date>`

------------------------------------------------------------------------

# 23. Postmortem Quality Checklist

``` text
[ ] Incident ID recorded
[ ] Severity justified
[ ] Timeline has timestamps
[ ] Customer impact quantified
[ ] Root cause identified
[ ] Contributing factors identified
[ ] Five Whys completed
[ ] Deployment correlation checked
[ ] Rollback details recorded
[ ] Verification results recorded
[ ] Communications recorded
[ ] Evidence references added
[ ] Corrective actions have owners
[ ] Preventive actions have due dates
[ ] Final status recorded
[ ] Required approvals completed
```

## AI Assistance & Attribution

> **AI Assistance:** This document was developed with AI-assisted drafting and analysis. The final technical decisions, thresholds, architecture alignment, implementation details, validation, and submission responsibility remain with the project author. The primary governing source for this deliverable is the NovaPay Zero-Downtime CI/CD Pipeline Assessment provided for this project.
