# NovaPay — RBI & PCI-DSS Mapping

## 1. Purpose

This document maps the NovaPay CI/CD pipeline controls to the specific RBI IT Risk Management and PCI-DSS v4.0 requirements identified in the assessment. The assessment requires compliance gates to be mapped to specific RBI sections and PCI-DSS requirements. 

## 2. RBI Mapping

| RBI Section | Requirement / Control Area | NovaPay CI/CD Implementation | Evidence |
|---|---|---|---|
| RBI 4.2 | Change management: testing, approval, rollback procedures | CI/CD gates, automated testing, deployment approvals, blue-green/canary deployment and automated rollback | PRs, test reports, approvals, deployment and rollback logs |
| RBI 4.3 | Segregation of duties between development and deployment | Separate developer/deployment roles, RBAC, protected branches/environments and independent production approval | PR approvals, RBAC records, deployment identity |
| RBI 5.1 | Vulnerability assessment must be performed regularly | SAST, DAST and dependency/CVE scanning gates | SonarQube, OWASP ZAP and Trivy reports |
| RBI 5.4 | Encryption of data in transit and at rest | Policy gate verifies TLS and encryption requirements | OPA/Kyverno results, infrastructure configuration |
| RBI 6.1 | Comprehensive audit trails for system changes | Immutable pipeline audit records for actor, commit, artifact, gate, approval and deployment | Structured JSON audit events |
| RBI 6.3 | Incident management and business continuity | Automated rollback, incident playbook and DR/recovery controls | Rollback logs, incident records, DR evidence |
| RBI 7.2 | Third-party risk management | Dependency scanning, SBOM, licence compliance and vendor/security evidence | SBOM, Trivy report, licence report |

These mappings follow the RBI control mapping provided in the assessment.

## 3. PCI-DSS v4.0 Mapping

| PCI-DSS Requirement | Requirement / Control Area | NovaPay CI/CD Implementation | Evidence |
|---|---|---|---|
| 6.2 | Bespoke software security | SAST, mandatory peer review and secure development gates | SonarQube report, PR review, gate result |
| 6.3 | Security vulnerabilities | Dependency scanning, CVE gating, SBOM and remediation | Trivy report, SBOM, remediation ticket |
| 6.4 | Public-facing web application protection | DAST using OWASP ZAP and WAF integration | ZAP report, WAF evidence |
| 6.5 | Change management | Controlled PR process, approvals, protected environments and rollback | PR, approvals, deployment logs |
| 10.2 | Audit logging | Structured audit events for security-relevant actions and changes | JSON audit records, centralized logs |
| 11.3 | Security testing / penetration testing | DAST and security-testing evidence against approved staging targets | ZAP/security test reports |

The assessment explicitly maps PCI-DSS 6.2 to SAST/peer review, 6.3 to dependency scanning/CVE gating and 6.4 to DAST/WAF.

## 4. Compliance Gate → Regulatory Mapping

| Gate | Control | RBI | PCI-DSS |
|---|---|---|---|
| G1 | SAST | 4.2, 5.1 | 6.2 |
| G2 | DAST | 4.2, 5.1 | 6.4, 11.3 |
| G3 | Dependency & CVE | 5.1, 7.2 | 6.3 |
| G4 | Licence Compliance | 7.2 | 6.2–6.3 |
| G5 | Kubernetes Policy | 4.2, 5.4, 6.1 | 6.2–6.5 |
| G6 | IaC Security | 4.2, 5.4 | 6.2–6.5 |
| G7 | Image Signing & Provenance | 6.1, 7.2 | 6.2–6.3 |
| G8 | SoD / Change / Audit | 4.2, 4.3, 6.1 | 6.2, 6.5, 10.2 |

## 5. RBI Control Flow

```text
Developer Commit
      |
      v
SAST / DAST / Dependency Scanning
      |
      +---- RBI 5.1
      v
Build + Test
      |
      v
Policy / Encryption Checks
      |
      +---- RBI 5.4
      v
Approval + Segregation of Duties
      |
      +---- RBI 4.2 / 4.3
      v
Deployment
      |
      v
Audit + Monitoring
      |
      +---- RBI 6.1
      v
Rollback / Incident Recovery
      |
      +---- RBI 6.3
```

## 6. PCI-DSS Control Flow

```text
Source Code
   |
   +--> Peer Review / SAST
   |       |
   |       +--> PCI-DSS 6.2
   |
   +--> Dependency / CVE Scan
   |       |
   |       +--> PCI-DSS 6.3
   |
   +--> DAST / WAF
   |       |
   |       +--> PCI-DSS 6.4 / 11.3
   |
   +--> Controlled Production Change
   |       |
   |       +--> PCI-DSS 6.5
   |
   +--> Audit Logging
           |
           +--> PCI-DSS 10.2
```

## 7. Compliance Decision

### Production PASS

Production promotion is permitted only when:

- all mandatory security gates PASS;
- required RBI controls are satisfied;
- required PCI-DSS controls are satisfied;
- required peer/production approvals exist;
- segregation of duties is satisfied;
- artifact provenance and signature are valid;
- audit evidence is generated.

### Production FAIL

Production promotion is blocked when:

- a mandatory security gate fails;
- a required approval is missing;
- an unauthorized identity attempts deployment;
- a required audit record is missing;
- a blocking vulnerability is detected;
- a required compliance policy fails;
- an expired exception is being used.

```text
ALL REQUIRED CONTROLS PASS
          |
          v
   COMPLIANCE CLEAR
          |
          v
 PRODUCTION PROMOTION

ANY REQUIRED CONTROL FAILS
          |
          v
   PRODUCTION BLOCKED
          |
          v
 REMEDIATE / VALID EXCEPTION
          |
          v
      RE-EVALUATE
```

## 8. Evidence Matrix

| Control | Primary Evidence |
|---|---|
| RBI 4.2 | PR, test results, approval, deployment/rollback log |
| RBI 4.3 | Reviewer/deployer identities, RBAC records |
| RBI 5.1 | SAST, DAST, Trivy reports |
| RBI 5.4 | TLS/encryption policy results |
| RBI 6.1 | Immutable JSON audit event |
| RBI 6.3 | Incident/rollback/DR records |
| RBI 7.2 | SBOM, licence and dependency reports |
| PCI 6.2 | SAST + peer review |
| PCI 6.3 | CVE/dependency scan + SBOM |
| PCI 6.4 | DAST + WAF evidence |
| PCI 6.5 | Change approval + deployment record |
| PCI 10.2 | Central/immutable audit logs |
| PCI 11.3 | Security/penetration testing reports |

## 9. Exception and Regulatory Control

A compliance exception is not a permanent bypass.

```text
Gate Failure
     |
     v
Risk Assessment
     |
     v
Exception Request
     |
     +-- Business Justification
     +-- Risk / Severity
     +-- Compensating Control
     +-- Named Owner
     +-- Named Approver
     +-- Expiry Timestamp
     |
     v
Independent Approval
     |
     v
Temporary Exception
     |
     v
AUTO-EXPIRY
     |
     v
Gate Re-evaluation
```

Every exception must be recorded as audit evidence and must have an explicit expiry. Emergency/hotfix changes may use an expedited process, but security and compliance gates remain enforced.

## 10. Assessment Traceability

| Assessment Requirement | Location |
|---|---|
| Specific RBI mapping | Section 2 |
| Specific PCI-DSS mapping | Section 3 |
| Gate-to-regulation mapping | Section 4 |
| Audit/evidence mapping | Section 8 |
| Formal exception control | Section 9 |
| RBI 4.2, 4.3, 5.1, 5.4, 6.1, 6.3, 7.2 | Section 2 |
| PCI-DSS 6.2–6.5, 10.2, 11.3 | Section 3 |

## Assessment Alignment

Day 5 requires compliance gate specifications, OPA policies and a gate orchestration diagram. This file provides the **RBI/PCI-DSS regulatory mapping component** of that deliverable.
