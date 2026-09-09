# NovaPay Incident Simulation — Communication Log

**Incident ID:** NOVAPAY-SIM-2026-001  
**Severity:** SEV-1  
**Scenario:** Friday 5:07 PM IST canary incident  
**Status:** Simulated / resolved

## 1. Communication Objectives

- notify the correct stakeholders quickly;
- state customer impact accurately;
- communicate containment and rollback;
- provide updates;
- communicate recovery;
- preserve an audit-ready record.

The assessment requires initial acknowledgement, regular updates, resolution notification and post-mortem communication. For SEV-1 it specifies regular updates every 30 minutes; this simulation also records immediate decision-point updates.

## 2. Stakeholders

| Stakeholder | Role | Reason |
|---|---|---|
| SRE on-call / Incident Commander | Operations | Triage and containment |
| SRE Lead | Reliability | Rollback |
| VP Engineering | Technical executive | SEV-1 escalation |
| CISO | Security | Emergency change/security risk |
| CTO | Executive sponsor | Business/technology risk |
| Release Manager | Change governance | Production change record |
| Compliance | Regulatory evidence | Incident governance |
| Product/Business owner | Customer impact | Payment/service impact |
| Status-page owner | External comms | Customer status |

## 3. Communication Timeline

### T+0 — 17:15
**Internal incident channel**

> **[SEV-1] NovaPay production incident detected.** HTTP 500 is 12%, PostgreSQL connection pool is exhausted, and payment gateway timeout is 35% during the canary. Canary promotion is frozen and rollback assessment is active.

### T+30s — 17:15:30
> **SEV-1 confirmed.** Customer-facing payment/API degradation is correlated with the active canary. Promotion is frozen. CTO, CISO and VP Engineering escalation is active.

### T+2m — 17:17
**Executive/incident update**

> Three critical signals remain active: HTTP 500 = 12%, PostgreSQL pool exhausted, payment gateway timeout = 35%. The canary is the primary suspected change source. Rollback to the last known healthy release is being prepared.

**Customer/status page**

> **Investigating:** Some customers may experience failed or delayed payment transactions. Our engineering team is investigating and working to restore normal service.

### T+5m — 17:20
> **Rollback initiated.** The production canary has been removed from customer traffic and the previous known-good release is being restored. Application, database and synthetic payment verification is in progress.

### T+8m — 17:23
> **Recovery verification in progress.** The previous release is serving production traffic. Initial application health, smoke-test and payment-flow checks are passing in the simulation. Database and payment indicators continue to be monitored.

### T+10m — 17:25
> **Service stabilizing.** Customer traffic remains on the known-good release. The faulty canary remains quarantined. Key indicators are stable. Incident remains open for observation and root-cause analysis.

### T+15m — 17:30
**Internal resolution**

> **SEV-1 recovered.** Production service has remained stable following rollback. Smoke tests and synthetic payment verification have passed in the simulation. The incident is moving to root-cause analysis. The emergency hotfix bypassed staging/environment-promotion validation; corrective actions will make mandatory promotion controls non-bypassable.

**Customer/status page**

> **Resolved:** The issue affecting some payment transactions has been resolved. Service has returned to normal operation. We are continuing to review the event and will take steps to prevent recurrence.

## 4. Regulatory/Compliance Communication

For a real incident, Compliance must determine notification obligations using actual duration, customer/transaction impact, data-integrity findings, system criticality and applicable RBI/NPCI/PCI-DSS/internal requirements.

The assessment's YES Bank simulation references a workflow for technology incidents exceeding 30 minutes. This simulation stabilized at approximately 15 minutes and does **not** claim that a real regulatory notification would be required.

**Simulation decision:** Regulatory notification requirement is not asserted; real-event assessment remains mandatory.

## 5. Communication Evidence Register

| ID | Evidence | Status |
|---|---|---|
| COM-001 | Incident declaration | Recorded |
| COM-002 | SEV-1 escalation | Recorded |
| COM-003 | CTO/CISO/VP Engineering notification | Recorded |
| COM-004 | Customer status acknowledgement | Recorded |
| COM-005 | Rollback notification | Recorded |
| COM-006 | Recovery verification update | Recorded |
| COM-007 | Resolution notification | Recorded |
| COM-008 | Root-cause communication | Recorded |
| COM-009 | Post-mortem reference | Required |

## 6. Communication Principles

- **Fast:** acknowledgement at T+0.
- **Factual:** use measured scenario values.
- **No public speculation:** exact application defect is not known.
- **Action-oriented:** clearly state freeze and rollback.
- **Audience-specific:** technical details internally; impact-focused wording externally.
- **Auditable:** retain timestamp, owner, audience, message and decision.

## AI Assistance & Attribution

> AI assistance was used to structure this simulation communication log from the supplied assessment. Messages are simulated templates, not records of real communications.
