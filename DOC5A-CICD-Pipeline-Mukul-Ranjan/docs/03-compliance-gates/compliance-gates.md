# NovaPay Compliance Gates

**Deliverable:** 3 — Compliance Gate Specifications  
**Day:** 5 — Compliance Gates

The assessment requires at least 6 automated compliance gates, precise pass/fail thresholds, remediation guidance, a formal time-bound exception workflow, a structured audit trail, and mapping to specific RBI and PCI-DSS requirements. This design uses **8 gates**. fileciteturn12file0turn12file7

## Gate 1 — SAST

**Purpose:** Detect source-code vulnerabilities before promotion.  
**Tool:** SonarQube  
**Input:** Source code, PR/commit, test and coverage results.  
**Threshold:** Critical = **0**; High ≤ **2**; line coverage ≥ **80%**; blocking quality failures = **0**. fileciteturn12file7  
**PASS:** All thresholds met.  
**FAIL:** Any threshold breached.  
**Remediation:** Block → ticket → fix → new commit → rerun SAST.  
**Exception:** CISO approval within **24h**, with justification, compensating control and expiry.  
**Evidence:** SonarQube report, commit SHA, coverage, ticket, exception record.  
**RBI:** 4.2, 5.1.  
**PCI-DSS:** 6.2.

## Gate 2 — DAST

**Purpose:** Detect runtime vulnerabilities in the staging application.  
**Tool:** OWASP ZAP  
**Input:** Running staging app, OpenAPI specification, approved test credentials.  
**Threshold:** Critical = **0**; High = **0**; authenticated scan = PASS; required API scope scanned = **100%**.  
**PASS:** All required checks pass.  
**FAIL:** Any blocking Critical/High finding or incomplete required scan.  
**Remediation:** Block → remediate → rescan.  
**Exception:** Risk-acceptance form + TRC approval, with expiry and compensating control. fileciteturn12file7  
**Evidence:** ZAP report, scan configuration, target/version, remediation/risk record.  
**RBI:** 4.2, 5.1.  
**PCI-DSS:** 6.4, 11.3.

## Gate 3 — Dependency & CVE

**Purpose:** Prevent vulnerable dependencies/images from reaching production.  
**Tool:** Trivy  
**Input:** Lock files, container image, SBOM, vulnerability scan results.  
**Threshold:** Critical CVEs = **0**; blocking CVSS ≥9.0 = **0**; SBOM = **required**; unscanned dependencies = **0**. fileciteturn12file7  
**PASS:** No blocking vulnerability and SBOM archived.  
**FAIL:** Critical/CVSS ≥9 vulnerability, missing SBOM, or incomplete scan.  
**Remediation:** Upgrade/replace dependency → rebuild → regenerate SBOM → rescan.  
**Exception:** Documented remediation window of **72h**, owner, compensating control and expiry.  
**Evidence:** Trivy report, SBOM, image digest, dependency lock file, ticket.  
**RBI:** 5.1, 7.2.  
**PCI-DSS:** 6.3.

## Gate 4 — License Compliance

**Purpose:** Prevent unacceptable open-source licensing risk.  
**Tool:** FOSSA / ScanCode  
**Input:** Dependency manifest, SBOM, package/license metadata.  
**Threshold:** GPL = **0**; AGPL = **0**; SSPL = **0**; unknown/unclassified licenses = **0**; unapproved exceptions = **0**. fileciteturn12file7  
**PASS:** All dependencies use approved licenses.  
**FAIL:** Prohibited or unknown license detected.  
**Remediation:** Remove/replace dependency → rebuild → regenerate SBOM → rescan.  
**Exception:** Legal-team sign-off with justification, interpretation, compensating control and expiry.  
**Evidence:** License report, SBOM, dependency inventory, legal approval.  
**RBI:** 7.2.  
**PCI-DSS:** 6.2–6.3.

## Gate 5 — Kubernetes Policy

**Purpose:** Prevent insecure Kubernetes resources from deployment.  
**Tool:** OPA/Rego + Kyverno  
**Input:** Helm-rendered/Kubernetes manifests, image metadata, namespace and security context.  
**Threshold:** Policy violations = **0**; privileged containers = **0**; plaintext secrets = **0**; missing resource limits = **0**; required security-context failures = **0**.  
**PASS:** All mandatory policies pass.  
**FAIL:** Any blocking policy violation.  
**Remediation:** Block → fix manifest/chart → rerender → reevaluate.  
**Exception:** Dual-approval override, time-bound and audited. fileciteturn12file7  
**Evidence:** OPA/Kyverno result, policy version/hash, rendered manifest, approval record.  
**RBI:** 4.2, 5.4, 6.1.  
**PCI-DSS:** 6.2–6.5.

## Gate 6 — Infrastructure / IaC Security

**Purpose:** Prevent insecure infrastructure configuration.  
**Tool:** Checkov + Terraform validation  
**Input:** Terraform code, plan, modules and provider configuration.  
**Threshold:** Critical IaC violations = **0**; privileged resources = **0**; missing resource limits = **0**; missing required encryption = **0**; unapproved public exposure = **0**.  
**PASS:** All blocking checks pass.  
**FAIL:** Any blocking IaC violation.  
**Remediation:** Fix Terraform → regenerate plan → rerun Checkov.  
**Exception:** Tech Lead exemption with documented risk, compensating control, expiry and audit evidence. fileciteturn12file7  
**Evidence:** Checkov report, Terraform plan, commit SHA, policy result, approval.  
**RBI:** 4.2, 5.4.  
**PCI-DSS:** 6.2–6.5.

## Gate 7 — Image Signing & Provenance

**Purpose:** Ensure only trusted and traceable artifacts can deploy.  
**Tool:** Cosign / Notary + OPA/Kyverno  
**Input:** Image, digest, Git SHA, SemVer, SBOM, provenance and signature.  
**Threshold:** Valid signature = **100% required**; missing signature = **0**; missing SBOM = **0**; missing provenance = **0**; `latest` production tags = **0**; unapproved registry images = **0**.  
**PASS:** Signature, digest, SBOM, provenance and registry verification all pass.  
**FAIL:** Any trust-chain requirement fails.  
**Remediation:** Rebuild/re-sign → regenerate evidence → verify digest → rerun.  
**Exception:** No normal unsigned-production bypass; emergency exception requires security/release approval, compensating control and auto-expiry.  
**Evidence:** Digest, signature verification, SBOM, provenance, registry record, Git SHA, SemVer.  
**RBI:** 6.1, 7.2.  
**PCI-DSS:** 6.2–6.3.  
The assessment requires signed artifacts, SemVer/Git-SHA traceability and rejection of unsigned images. fileciteturn12file4

## Gate 8 — Segregation of Duties / Change / Audit

**Purpose:** Prevent one person from independently creating, approving and deploying a production change.  
**Tool:** GitHub branch protection, protected environments, RBAC and immutable audit records  
**Input:** PR, commit identity/signature, reviewer identity, deployment identity, change ticket and approvals.  
**Threshold:** Independent reviews ≥ **1**; direct push to protected main = **0**; self-approval = **0**; production approvals = **2**; unauthorized deployment identities = **0**; missing audit records = **0**.  
**PASS:** All review, approval, identity and audit requirements pass.  
**FAIL:** Any SoD/approval/audit violation.  
**Remediation:** Block → correct authorization/reviewer → rerun authorization checks; preserve failed attempt as evidence.  
**Exception:** Emergency hotfix may use expedited approval but must still pass security/compliance gates; independent review and expiry are required.  
**Evidence:** PR, reviewers, timestamps, signed commit, branch-protection result, deployment identity, change ticket and audit event.  
**RBI:** 4.2, 4.3, 6.1.  
**PCI-DSS:** 6.2, 6.5, 10.2. fileciteturn12file3turn12file9

---

# Regulatory Mapping Summary

| Gate | RBI | PCI-DSS |
|---|---|---|
| SAST | 4.2, 5.1 | 6.2 |
| DAST | 4.2, 5.1 | 6.4, 11.3 |
| Dependency | 5.1, 7.2 | 6.3 |
| License | 7.2 | 6.2–6.3 |
| Kubernetes Policy | 4.2, 5.4, 6.1 | 6.2–6.5 |
| IaC Security | 4.2, 5.4 | 6.2–6.5 |
| Image Provenance | 6.1, 7.2 | 6.2–6.3 |
| SoD/Change/Audit | 4.2, 4.3, 6.1 | 6.2, 6.5, 10.2 |

The RBI and PCI-DSS mappings above follow the assessment's regulatory framework. fileciteturn12file3

---

# Formal Exception Workflow

```text
Gate FAIL
   ↓
Risk assessment
   ↓
Exception request
   ↓
Business justification + severity
+ compensating control + owner
+ approver + expiry timestamp
   ↓
Independent approval
   ↓
Temporary exception
   ↓
AUTO-EXPIRY
   ↓
Gate re-evaluation
```

**Rules:** Every exception has an owner, approver, justification, compensating control and expiry. Expired exceptions cannot authorize deployment. Security/regulatory/SoD exceptions require the appropriate independent approval. Direct silent bypass is prohibited.

---

# Structured Audit Trail

```json
{
  "event_type": "compliance_gate_decision",
  "event_id": "uuid",
  "timestamp": "2026-08-30T10:00:00Z",
  "pipeline": {
    "run_id": "12345",
    "repository": "novapay",
    "commit_sha": "abc123",
    "branch": "main"
  },
  "artifact": {
    "version": "2.4.1+build.123",
    "image_digest": "sha256:...",
    "sbom_reference": "sbom-123"
  },
  "gate": {
    "gate_id": "GATE-01",
    "name": "SAST",
    "tool": "SonarQube",
    "status": "PASS",
    "thresholds": {
      "critical": 0,
      "high": 2,
      "coverage_percent": 80
    },
    "observed": {
      "critical": 0,
      "high": 1,
      "coverage_percent": 86
    }
  },
  "regulatory_mapping": {
    "rbi": ["4.2", "5.1"],
    "pci_dss": ["6.2"]
  },
  "decision": {
    "result": "PASS",
    "decided_by": "automation",
    "reason": "All mandatory thresholds satisfied"
  },
  "exception": null,
  "evidence": [
    "sonarqube-report",
    "coverage-report"
  ]
}
```

---

# Overall Production Decision

```text
G1 SAST              PASS
G2 DAST              PASS
G3 Dependency        PASS
G4 License           PASS
G5 Kubernetes Policy PASS
G6 IaC               PASS
G7 Image Provenance  PASS
G8 SoD / Audit       PASS
          ↓
   COMPLIANCE CLEAR
          ↓
Production promotion allowed
```

Any mandatory failure:

```text
FAIL → BLOCK → REMEDIATE → RE-RUN
```

or, where formally permitted:

```text
FAIL → VALID EXCEPTION → TEMPORARY APPROVAL → AUTO-EXPIRY → RE-EVALUATE
```

---

# Day 5 Checklist

- [x] 8 compliance gates
- [x] Purpose, tool and input for every gate
- [x] Numeric thresholds
- [x] PASS / FAIL criteria
- [x] Remediation guidance
- [x] Formal exception workflow
- [x] Time-bound approval and auto-expiry
- [x] Structured audit trail / JSON format
- [x] RBI mapping
- [x] PCI-DSS mapping
- [x] 3+ OPA/Rego policy files under `pipeline/policies/`
- [x] Gate orchestration diagram
- [x] Git commit: `feat: compliance gate definitions with RBI/PCI-DSS mapping`
- [x] Git commit: `feat: OPA policy files for NovaPay`
- [ ] Push all Day 5 files

**Assessment expected output:** compliance gate specifications, OPA policies and orchestration diagram (Deliverable 3). fileciteturn12file0




---

## Cross-Deliverable References

- [Deliverable 1 — Pipeline Architecture](../01-pipeline-architecture/architecture.md)
- [Deliverable 2 — Deployment Strategies](../02-deployment-strategies/deployment-strategy.md)
- [Deliverable 4 — Database Migration](../04-database-migration/database-migration-strategy.md)
- [Deliverable 5 — Environment Promotion](../05-environment-promotion/environment-promotion-workflow.md)
- [Deliverable 6 — Rollback Specification](../06-rollback-specification/rollback-specification.md)
- [Deliverable 8 — Observability](../08-observability/observability-strategy.md)


## Gate Orchestration Diagram

The compliance gate orchestration is documented in the following repository artifacts:

- [Compliance Gate Orchestration — Draw.io](./diagrams/compliance-gate-orchestration.drawio)
- [Compliance Gate Orchestration — PNG](./diagrams/compliance-gate-orchestration.png)

## AI Assistance & Attribution

> **AI Assistance:** This document was developed with AI-assisted drafting and analysis. The final technical decisions, thresholds, architecture alignment, implementation details, validation, and submission responsibility remain with the project author. The primary governing source for this deliverable is the NovaPay Zero-Downtime CI/CD Pipeline Assessment provided for this project.