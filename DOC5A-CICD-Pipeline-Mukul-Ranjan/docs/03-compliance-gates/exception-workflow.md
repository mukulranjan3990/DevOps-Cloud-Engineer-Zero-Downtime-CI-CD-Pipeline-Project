# NovaPay — Compliance Exception Workflow

## 1. Purpose

This document defines the formal exception process for NovaPay CI/CD compliance gates.

The assessment requires every compliance gate to have a **formal exception workflow with time-bound approvals**, including who approves the exception and how expiry is enforced. fileciteturn15file1

An exception is a **temporary, controlled risk acceptance**. It is not a permanent bypass of security or compliance controls.

---

# 2. Core Principles

1. **Default decision is FAIL/BLOCK.**
2. An exception may be requested only after a gate failure is recorded.
3. Every exception must have a documented business justification.
4. Every exception must identify the security/compliance risk.
5. Every exception must have a named owner.
6. Every exception must have a named approver.
7. Every exception must define a compensating control where applicable.
8. Every exception must have an explicit expiry timestamp.
9. Expired exceptions automatically become invalid.
10. An expired exception cannot authorize production deployment.
11. Exception approval and usage must be recorded in the audit trail.
12. Security and compliance gates must not be silently skipped.

---

# 3. Standard Exception Workflow

```text
                 COMPLIANCE GATE
                       |
                       v
                  GATE = FAIL
                       |
                       v
                Pipeline BLOCKED
                       |
                       v
                 Risk Assessment
                       |
                       v
              Exception Requested?
                  /          \
                NO            YES
                |              |
                v              v
             Remediate     Exception Record
                |              |
                v              +-- Failure details
             Re-run            +-- Risk/severity
                               +-- Business reason
                               +-- Compensating control
                               +-- Owner
                               +-- Approver
                               +-- Expiry timestamp
                                      |
                                      v
                              Independent Approval
                                  /          \
                                FAIL         PASS
                                |             |
                                v             v
                             BLOCKED     Temporary Exception
                                              |
                                              v
                                       Controlled Promotion
                                              |
                                              v
                                          AUTO-EXPIRY
                                              |
                                              v
                                       Gate Re-evaluation
```

---

# 4. Exception Request Requirements

Every exception request must contain:

| Field | Required |
|---|---|
| Exception ID | Yes |
| Gate ID | Yes |
| Gate name | Yes |
| Pipeline run ID | Yes |
| Repository | Yes |
| Commit SHA | Yes |
| Artifact/image digest | Yes |
| Failed threshold | Yes |
| Observed value | Yes |
| Risk severity | Yes |
| Business justification | Yes |
| Risk assessment | Yes |
| Compensating control | Yes, where applicable |
| Remediation plan | Yes |
| Remediation owner | Yes |
| Requested by | Yes |
| Approver | Yes |
| Requested timestamp | Yes |
| Approval timestamp | Yes |
| Expiry timestamp | Yes |
| Audit/evidence reference | Yes |
| Status | Yes |

---

# 5. Gate-Specific Exception Approval

The assessment provides the following exception processes for the compliance gates. fileciteturn15file1

| Gate | Normal Failure | Required Approval / Exception | Time Limit |
|---|---|---|---|
| **SAST** | Pipeline blocked / auto-ticket | **CISO approval** | **Within 24h** |
| **DAST** | Pipeline blocked | **Risk acceptance form + TRC** | Time-bound approval |
| **Dependency** | Pipeline blocked for CVSS ≥9.0 | Documented remediation exception | **72h remediation window** |
| **Licence** | Legal review triggered | **Legal team sign-off** | Time-bound |
| **Policy** | Deployment rejected | **Dual approval override** | Time-bound |
| **Infrastructure** | PR blocked | **Tech Lead exemption** | Time-bound |

> These are the assessment-defined exception mechanisms. Project implementation should enforce the corresponding approval before an exception can affect a production decision. fileciteturn15file1

---

# 6. SAST Exception

### Trigger

SAST fails because the defined threshold is breached, for example:

- Critical finding > 0
- High findings > 2
- Coverage < 80%

### Normal action

```text
SAST FAIL
   ↓
Pipeline BLOCK
   ↓
Auto-ticket
   ↓
Developer remediation
   ↓
Re-run SAST
```

### Exception

**Approver:** CISO  
**Approval limit:** Within **24 hours**  
**Required evidence:**

- SAST report
- finding ID
- risk assessment
- business justification
- compensating control
- remediation ticket
- CISO approval
- expiry timestamp

### Expiry

After expiry, the exception is invalid and the SAST gate must pass again before production promotion.

---

# 7. DAST Exception

### Trigger

OWASP ZAP reports a blocking Critical/High vulnerability.

### Normal action

```text
DAST FAIL
   ↓
Production promotion BLOCKED
   ↓
Application remediation
   ↓
DAST re-scan
```

### Exception

**Approval:** Risk acceptance form + TRC review/approval.

The assessment identifies risk acceptance and TRC involvement for the DAST exception process. fileciteturn15file1

### Required evidence

- ZAP report
- vulnerability details
- affected endpoint
- risk assessment
- business justification
- compensating control
- TRC approval
- expiry timestamp
- remediation ticket

### Expiry

The exception automatically becomes invalid at its expiry time.

---

# 8. Dependency Exception

### Trigger

Dependency scanning detects a blocking vulnerability, particularly CVSS ≥9.0.

### Normal action

```text
Dependency FAIL
   ↓
Pipeline BLOCK
   ↓
Upgrade / replace dependency
   ↓
Rebuild + rescan
```

### Exception

**Remediation window:** **72 hours** as specified by the assessment. fileciteturn15file1

### Required evidence

- Trivy report
- CVE/CVSS information
- affected package
- business justification
- risk assessment
- remediation owner
- remediation ticket
- compensating control
- expiry timestamp

### Expiry

After 72 hours, the exception expires and the dependency gate must be passed again.

---

# 9. Licence Exception

### Trigger

A dependency violates the defined licence policy, such as GPL/AGPL/SSPL.

### Normal action

```text
Licence FAIL
   ↓
Legal Review
   ↓
Remove / Replace dependency
   ↓
Re-scan
```

### Exception

**Approver:** Legal team.

The assessment explicitly requires legal-team sign-off for the licence exception process. fileciteturn15file1

### Required evidence

- licence scan
- dependency/SBOM record
- licence information
- legal assessment
- business justification
- approved exception
- expiry timestamp

### Expiry

An expired legal exception cannot permit the dependency to remain in the production release.

---

# 10. Kubernetes Policy Exception

### Trigger

OPA/Kyverno rejects a Kubernetes resource.

Examples:

- privileged container
- plaintext secret
- missing security context
- missing required resource limits
- other mandatory policy violation

### Normal action

```text
Policy FAIL
   ↓
Deployment REJECTED
   ↓
Fix manifest
   ↓
Re-evaluate policy
```

### Exception

**Approval:** Dual approval override.

The assessment specifies a dual-approval override for the policy gate. fileciteturn15file1

### Required evidence

- failed policy rule
- resource/manifest
- risk assessment
- business justification
- compensating control
- two approvers
- expiry timestamp
- remediation ticket

### Expiry

The policy exception automatically becomes invalid when the expiry timestamp is reached.

---

# 11. Infrastructure / IaC Exception

### Trigger

Checkov/Terraform detects a blocking infrastructure policy violation.

### Normal action

```text
IaC FAIL
   ↓
PR BLOCKED
   ↓
Fix Terraform
   ↓
Terraform plan
   ↓
Checkov re-scan
```

### Exception

**Approver:** Tech Lead exemption.

The assessment explicitly specifies a Tech Lead exemption for the Infrastructure gate. fileciteturn15file1

### Required evidence

- Checkov report
- Terraform plan
- failed policy
- risk assessment
- business justification
- compensating control
- Tech Lead approval
- expiry timestamp
- remediation ticket

### Expiry

The exception becomes invalid automatically at expiry.

---

# 12. Exception Status Lifecycle

```text
REQUESTED
    |
    v
UNDER_REVIEW
    |
    +-------> REJECTED
    |
    v
APPROVED
    |
    v
ACTIVE
    |
    +-------> REMEDIATED
    |
    v
EXPIRED
    |
    v
CLOSED
```

### Status definitions

| Status | Meaning |
|---|---|
| `REQUESTED` | Exception submitted |
| `UNDER_REVIEW` | Waiting for required approval |
| `APPROVED` | Authorized but not yet activated |
| `ACTIVE` | Temporary exception is currently valid |
| `REJECTED` | Exception denied |
| `REMEDIATED` | Original failure fixed |
| `EXPIRED` | Time limit reached |
| `CLOSED` | Exception permanently closed |

---

# 13. Automatic Expiry

Auto-expiry is mandatory for temporary exceptions.

```text
Exception Created
       |
       v
expiry_at = approved expiry timestamp
       |
       v
Exception ACTIVE
       |
       v
Current Time >= expiry_at
       |
       v
Exception INVALID
       |
       v
Production Deployment BLOCKED
       |
       v
Gate Must PASS
```

### Enforcement rules

- The pipeline must compare the current time with `expires_at`.
- `ACTIVE` is valid only before `expires_at`.
- `EXPIRED` exceptions cannot override a failed gate.
- Expiry must be recorded as an audit event.
- A new exception requires a new approval; it must not silently extend the old exception.

---

# 14. Emergency Hotfix Workflow

NovaPay requires emergency hotfixes to have an expedited path, but the assessment states that hotfixes must still go through security and compliance gates. They are **expedited, not bypassed**. fileciteturn15file9

```text
Emergency Hotfix
      |
      v
Expedited PR / Approval
      |
      v
Security Gates
      |
      v
Compliance Gates
      |
      v
Production Approval
      |
      v
Controlled Deployment
      |
      v
Post-Deployment Verification
```

### Hotfix rules

- No silent security-gate bypass.
- Required approvals remain auditable.
- Security/compliance gates remain enforced.
- Any temporary exception must have an owner and expiry.
- Post-deployment review must verify the emergency change.

---

# 15. Structured Exception Audit Record

Every exception decision must produce a structured audit event.

```json
{
  "event_type": "compliance_exception",
  "event_id": "uuid",
  "timestamp": "2026-08-30T10:00:00Z",

  "exception": {
    "exception_id": "EXC-0001",
    "gate_id": "GATE-01",
    "gate_name": "SAST",
    "status": "ACTIVE",

    "failure": {
      "threshold": "Critical findings = 0",
      "observed": "1 Critical finding",
      "severity": "CRITICAL"
    },

    "business_justification": "Documented emergency business requirement",

    "risk": {
      "level": "HIGH",
      "description": "Temporary acceptance of identified security risk"
    },

    "compensating_control": "Additional monitoring and restricted deployment scope",

    "remediation": {
      "ticket_id": "SEC-1234",
      "owner": "security-team",
      "target": "2026-08-31T10:00:00Z"
    },

    "approval": {
      "requested_by": "release-engineer",
      "approved_by": "ciso",
      "approved_at": "2026-08-30T10:05:00Z"
    },

    "expires_at": "2026-08-31T10:05:00Z"
  },

  "pipeline": {
    "run_id": "12345",
    "repository": "novapay",
    "commit_sha": "abc123"
  },

  "evidence": [
    "sast-report",
    "risk-assessment",
    "approval-record",
    "remediation-ticket"
  ]
}
```

---

# 16. Exception Decision Logic

```text
                GATE FAIL
                    |
                    v
             Can it be fixed?
              /           \
            YES            NO
            |               |
            v               v
         Remediate     Exception Needed
            |               |
            v               v
          Re-run       Risk Assessment
                            |
                            v
                     Required Approval
                       /          \
                     NO            YES
                     |              |
                     v              v
                  BLOCK          ACTIVE
                                    |
                                    v
                              Expiry Timer
                                    |
                         +----------+----------+
                         |                     |
                      Remediated             Expired
                         |                     |
                         v                     v
                       CLOSE                 BLOCK
                                               |
                                               v
                                          Re-evaluate
```

---

# 17. Production Protection Rule

```text
Exception ACTIVE + All Other Gates PASS
                |
                v
      Controlled Production Release

Exception EXPIRED
       OR
Exception REJECTED
       OR
Required Approval Missing
       |
       v
   PRODUCTION BLOCKED
```

A valid exception may temporarily control the specific failed gate only when the assessment-defined approval process has been completed. It must never become a general bypass of the CI/CD security and compliance controls.

---

# 18. Exception Evidence Checklist

For every exception, retain:

- [ ] Exception ID
- [ ] Gate ID
- [ ] Failed threshold
- [ ] Observed value
- [ ] Risk classification
- [ ] Business justification
- [ ] Compensating control
- [ ] Remediation plan
- [ ] Remediation ticket
- [ ] Named owner
- [ ] Required approver
- [ ] Approval timestamp
- [ ] Expiry timestamp
- [ ] Pipeline run ID
- [ ] Commit SHA
- [ ] Artifact/image digest
- [ ] Security/compliance scan report
- [ ] Final remediation evidence
- [ ] Closure/expiry audit event

---

# 19. Assessment Alignment

This file satisfies the **formal exception workflow** component of the Day 5 Compliance Gates deliverable:

- [x] Who approves each exception
- [x] Time-bound approvals/windows
- [x] Formal exception request
- [x] Risk assessment
- [x] Business justification
- [x] Compensating controls
- [x] Named owner
- [x] Explicit expiry
- [x] Automatic expiry behavior
- [x] Audit trail
- [x] Remediation and re-evaluation
- [x] Emergency hotfix path without bypassing security/compliance gates

The assessment's Day 5 expected output is **compliance gate specifications, OPA policies and a gate orchestration diagram**; this file is the dedicated exception-workflow component of that deliverable. fileciteturn15file8
