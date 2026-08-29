# NovaPay CI/CD Pipeline — Stage Specifications

**Deliverable:** 1 — Pipeline Architecture  
**Document:** Pipeline Stage Specifications  
**Version:** v1.0  
**Status:** Day 2 architecture baseline  
**Application:** NovaPay Digital Bank  
**Pipeline target:** Commit-to-production under 2 hours for the primary blue-green release path  
**Availability target:** Five-nines (99.999%)  
**Primary CI platform:** GitHub Actions  
**Primary CD platform:** Argo CD  
**Kubernetes traffic management:** Istio  
**Progressive delivery:** Argo Rollouts / Istio  
**Database:** PostgreSQL 16  
**Migration pattern:** Expand → Migrate → Contract

---

## 1. Architecture Objective

NovaPay requires a production-grade CI/CD pipeline for regulated banking workloads. The pipeline provides automated build, test, security, compliance, deployment, verification, audit evidence, and rollback controls.

The eight canonical stages follow the assessment structure:

1. Source Control & Trigger
2. Build & Compilation
3. Static Analysis & SAST
4. Dependency & Container Scanning
5. Integration & Contract Testing
6. Dynamic Analysis & DAST
7. Policy & Compliance Gates
8. Deployment & Verification

The architecture separates fast CI validation from production promotion controls. Security and compliance controls operate as blocking gates rather than advisory checks.

---

## 2. Pipeline Flow

```text
Developer Commit / Pull Request
              |
              v
+-----------------------------+
| 1. Source Control & Trigger |
+--------------+--------------+
               |
               v
+-----------------------------+
| 2. Build & Compilation      |
| Maven + JUnit + Docker      |
+--------------+--------------+
               |
       +-------+-------+
       |       |       |
       v       v       v
    Unit     SAST    Trivy/SBOM
    Tests   Scan     Scan
       |       |       |
       +-------+-------+
               |
               v
+-----------------------------+
| 5. Integration & Contract   |
| Pact + Testcontainers       |
+--------------+--------------+
               |
               v
+-----------------------------+
| 6. DAST                     |
| OWASP ZAP                   |
+--------------+--------------+
               |
               v
+-----------------------------+
| 7. Policy & Compliance      |
| OPA/Kyverno + Cosign        |
+--------------+--------------+
               |
           PASS / FAIL
           /        \
        FAIL        PASS
         |           |
       BLOCK         v
                8. Deploy &
                   Verify
                     |
              +------+------+
              |             |
           HEALTHY      UNHEALTHY
              |             |
              v             v
          PROMOTE       ROLLBACK
```

---

## 3. Timing Model

### 3.1 Primary commit-to-production path

The primary release path uses blue-green production promotion.

| Stage | Estimated duration | Execution model |
|---|---:|---|
| 1. Source Control & Trigger | 2 min | Sequential |
| 2. Build & Compilation | 12 min | Sequential |
| 3. Static Analysis & SAST | 4 min | Parallel |
| 4. Dependency & Container Scanning | 6 min | Parallel |
| 5. Integration & Contract Testing | 18 min | Sequential |
| 6. Dynamic Analysis & DAST | 10 min | Sequential |
| 7. Policy & Compliance Gates | 5 min | Sequential |
| 8. Deployment & Verification | 20 min | Sequential |
| **Critical-path total** | **77 min** | **Under 2 hours** |

### 3.2 Critical-path calculation

```text
Stage 1
  2 min
   +
Stage 2
 12 min
   +
max(Stage 3, Stage 4)
  max(4, 6) = 6 min
   +
Stage 5
 18 min
   +
Stage 6
 10 min
   +
Stage 7
  5 min
   +
Stage 8
 20 min
   =
77 minutes
```

The SAST and dependency/container scanning jobs execute in parallel after the build artifact becomes available. Parallel execution reduces the critical path by 4 minutes compared with serial execution of stages 3 and 4.

### 3.3 Canary timing

Canary deployment remains available as a progressive-delivery strategy.

| Canary phase | Traffic | Assessment duration | Purpose |
|---|---:|---:|---|
| Canary | 1–2% | 15 min | Initial health validation |
| Early adopter | 5–10% | 30 min | Error and latency validation |
| Expansion | 25–50% | 60 min | SLO validation |
| Full rollout | 100% | 24 hr bake | Stability confirmation |

The 24-hour bake represents post-rollout stability monitoring and does not form part of the synchronous commit-to-production target. Blue-green provides the primary sub-2-hour release path.

---

# 4. Stage 1 — Source Control & Trigger

## Purpose

Provide controlled entry into the CI/CD system with traceable source history, protected branches, authenticated commits, and automated workflow initiation.

## Tooling

| Tool | Recommended version / control |
|---|---|
| Git | Current supported release |
| GitHub | Managed repository |
| GitHub Actions | Workflow automation |
| GPG / SSH signing | Required for protected branches |
| GitHub Branch Protection | Required |

## Inputs

- Source code
- Pull request
- Git commit
- Commit metadata
- Branch metadata
- Commit signature
- Repository event

## Processing

1. Developer creates a branch.
2. Pull request targets the protected default branch.
3. Repository protection rules validate required approvals and checks.
4. Commit signature verification runs.
5. GitHub Actions receives a push or pull-request event.
6. Commit SHA becomes the immutable pipeline reference.
7. Pipeline run identifier becomes part of the audit record.

## Outputs

- Validated commit SHA
- Pull-request status
- Pipeline run ID
- Source revision metadata
- Initial audit event

## Quality Gate

| Gate | Pass condition |
|---|---|
| Pull request | Required review completed |
| Branch protection | Active |
| Direct default-branch push | Blocked |
| Commit signature | Valid |
| Source revision | Immutable commit SHA recorded |
| Required checks | Configured |

## Failure Mode

- Invalid commit signature
- Missing approval
- Protected-branch violation
- Missing required check
- Invalid workflow trigger

## Failure Handling

```text
Validation failure
      |
      v
Pull request blocked
      |
      v
Audit event recorded
      |
      v
Developer remediation
      |
      v
New commit / validation
```

No deployment job starts after a Stage 1 failure.

## Retry / Skip Logic

- Automatic retry: GitHub Actions runner or transient platform failure only.
- Application validation failure: no automatic retry.
- Skip: prohibited for branch protection and signature controls.
- Re-run: permitted after remediation.

## Evidence

- Commit SHA
- Pull-request approval record
- Signature verification result
- Workflow run record
- Branch protection status

## SLA

**Target: ≤ 3 minutes**

## Estimated duration

**2 minutes**

## Configuration
```yaml
required_reviewers: 2
require_signed_commits: true
allow_force_push: false
allow_direct_main_push: false
```

---

# 5. Stage 2 — Build & Compilation

## Purpose

Produce a reproducible, versioned, deployable application artifact and container image while validating unit-test quality.

## Tooling

| Tool | Purpose |
|---|---|
| Java 21 | Runtime / compilation |
| Maven | Dependency resolution and build |
| JUnit 5 | Unit testing |
| Docker | Container image creation |
| GitHub Actions | Job execution |
| GHCR / ECR | Artifact registry |

## Inputs

- Source repository
- `pom.xml`
- Dependency lock/version constraints
- Maven settings
- Dockerfile
- Test source
- Commit SHA

## Processing

1. Checkout immutable commit SHA.
2. Configure Java 21.
3. Restore dependency cache.
4. Resolve dependencies.
5. Compile source.
6. Execute unit tests.
7. Generate coverage report.
8. Build application JAR.
9. Build multi-stage container image.
10. Tag image using SemVer and Git SHA.
11. Publish immutable image to the registry.

## Outputs

- Compiled JAR
- Container image
- Unit-test report
- Coverage report
- Build metadata
- Immutable image tag

Example:

```text
novapay-payment:1.4.2-git.a83f92d
```

## Quality Gate

| Gate | Threshold |
|---|---:|
| Unit-test pass rate | 100% |
| Line coverage | ≥ 80% |
| Branch coverage | ≥ 70% |
| Compilation | PASS |
| Artifact generation | PASS |
| Image build | PASS |
| Production image tag | SemVer + Git SHA |
| `latest` production tag | Prohibited |

## Failure Mode

- Compilation failure
- Unit-test failure
- Coverage below threshold
- Dependency resolution failure
- Docker build failure
- Registry push failure

## Failure Handling

```text
Build failure
     |
     +--> Test failure --------+
     |                         |
     +--> Coverage failure ----+--> Pipeline blocked
     |                         |
     +--> Image failure -------+
                               |
                               v
                         Remediation
                               |
                               v
                           New commit
```

## Retry / Skip Logic

- Dependency download timeout: retry up to 2 times.
- Registry transient error: retry up to 2 times.
- Test failure: no automatic retry for final result.
- Coverage failure: no skip.
- Build failure: no deployment continuation.

## Evidence

- Build log
- Unit-test report
- Coverage report
- Artifact checksum
- Image digest
- Image tag
- Registry publication record

## SLA

**Target: ≤ 15 minutes**

## Estimated duration

**12 minutes**

## Configuration
<<<<<<< HEAD
```text
line_coverage_min = 80%
branch_coverage_min = 70%
unit_tests_required = true
production_tag = SemVer + Git SHA
latest_tag_in_production = prohibited
=======
```yaml
line_coverage_min: 80%
branch_coverage_min: 70%
unit_tests_required: true
production_tag: SemVer + Git SHA
latest_tag_in_production: prohibited
>>>>>>> regular
```

---

# 6. Stage 3 — Static Analysis & SAST

## Purpose

Identify source-code vulnerabilities, security weaknesses, code-quality defects, banking-specific coding risks, and excessive technical debt before environment promotion.

## Tooling

**Primary:** SonarQube

Optional supplementary analysis:

- Semgrep
- Secret scanning

## Inputs

- Source code
- Coverage report
- SonarQube quality profile
- Banking security rules
- Commit metadata

## Processing

1. Analyze source code.
2. Apply standard quality rules.
3. Apply banking-specific rules.
4. Evaluate security hotspots.
5. Evaluate vulnerabilities.
6. Evaluate code smells.
7. Evaluate technical debt.
8. Evaluate coverage.
9. Generate quality-gate result.

## Banking-specific analysis

- PII handling
- Encryption API usage
- SQL injection patterns
- Sensitive data logging
- Insecure cryptography
- Hard-coded credentials

## Outputs

- SAST report
- Vulnerability findings
- Quality-gate result
- Coverage analysis
- Technical-debt result

## Quality Gate

| Control | Threshold |
|---|---:|
| Critical vulnerabilities | 0 |
| High vulnerabilities | ≤ 2 |
| New-code technical debt | ≤ 5% |
| Line coverage | ≥ 80% |
| Branch coverage | ≥ 70% |

## Failure Mode

- Critical vulnerability
- High vulnerability threshold exceeded
- Technical debt threshold exceeded
- Banking rule violation
- Analysis failure

## Failure Handling

```text
SAST finding
     |
     v
Quality gate = FAIL
     |
     v
Pipeline blocked
     |
     v
Security / development remediation
     |
     v
New commit
     |
     v
SAST re-run
```

## Retry / Skip Logic

- Scanner infrastructure failure: one controlled retry.
- Finding-based failure: no automatic retry.
- Quality-gate skip: prohibited.
- False positive: formal review and documented suppression only.

## Evidence

- SonarQube project report
- Quality-gate result
- Finding list
- Coverage report
- Suppression record, when applicable

## SLA

**Target: ≤ 5 minutes**

## Estimated duration

**4 minutes**

## Configuration
```text
quality_gate = NovaPay-Production
critical_vulnerabilities = 0
high_vulnerability_limit = 2
new_code_technical_debt_limit = 5%
```

---

# 7. Stage 4 — Dependency & Container Scanning

## Purpose

Detect known vulnerabilities, unsafe packages, license violations, weak base images, and software-supply-chain risks.

## Tooling

- Trivy
- CycloneDX / SPDX SBOM
- Cosign
- GHCR / ECR registry

## Inputs

- Container image
- Image digest
- Maven dependencies
- Operating-system packages
- Base image metadata
- SBOM configuration

## Processing

1. Scan application dependencies.
2. Scan operating-system packages.
3. Scan container image.
4. Generate SBOM.
5. Evaluate CVSS severity.
6. Evaluate license policy.
7. Validate image provenance.
8. Prepare signing/attestation evidence.

## Outputs

- Vulnerability report
- SBOM
- License report
- Image provenance result
- Image digest
- Security evidence

## Quality Gate

| Control | Threshold |
|---|---:|
| Critical CVEs | 0 |
| High CVEs | Block when CVSS > 8.0 |
| SBOM | Required |
| SBOM format | CycloneDX or SPDX |
| GPL / AGPL / SSPL | Block unless formally approved |
| Base image provenance | Approved source required |
| Image digest | Required |

The assessment also defines a dependency gate using zero Critical CVEs and SBOM generation, with blocking at CVSS ≥ 9.0 in the compliance-gate table. Stage 4 uses the stricter operational rule of blocking High findings above CVSS 8.0; the compliance gate retains CVSS ≥ 9.0 as a hard dependency control.

## Failure Mode

- Critical CVE
- High CVSS threshold exceeded
- Missing SBOM
- Disallowed license
- Untrusted base image
- Scan failure

## Failure Handling

```text
Security scan
     |
     v
Finding / policy violation
     |
     v
Pipeline blocked
     |
     v
Dependency or image remediation
     |
     v
Image rebuild
     |
     v
Rescan
```

## Retry / Skip Logic

- Registry timeout: retry up to 2 times.
- Scanner service failure: controlled retry.
- Vulnerability finding: no skip.
- Formal exception: separate compliance workflow with time-bound approval.

## Evidence

- Trivy report
- SBOM
- Image digest
- License report
- Provenance metadata
- Exception record

## SLA

**Target: ≤ 8 minutes**

## Estimated duration

**6 minutes**

## Configuration
```text
critical_cve_limit = 0
high_cve_block_threshold = CVSS > 8.0
sbom_required = true
sbom_format = CycloneDX or SPDX
unapproved_license = BLOCK
trusted_base_image_required = true
```


---

# 8. Stage 5 — Integration & Contract Testing

## Purpose

Validate service-to-service compatibility, database integration, API backward compatibility, and end-to-end application behavior.

## Tooling

- Pact
- JUnit 5
- Testcontainers
- PostgreSQL
- RabbitMQ
- Redis
- Kubernetes ephemeral namespace

## Inputs

- Signed container image
- Service configuration
- Consumer contracts
- Provider contracts
- API definitions
- Test data
- Database schema
- Dependent services

## Processing

1. Provision an ephemeral Kubernetes namespace.
2. Deploy required service dependencies.
3. Start PostgreSQL, RabbitMQ, Redis, and application services.
4. Execute integration tests.
5. Execute Pact consumer-driven contract tests.
6. Validate backward compatibility.
7. Validate database integration.
8. Establish performance baseline.
9. Destroy the ephemeral environment after test completion.

## Outputs

- Integration-test report
- Contract-test report
- API compatibility result
- Database integration result
- Performance baseline
- Ephemeral environment evidence

## Quality Gate

| Control | Threshold |
|---|---|
| Integration tests | 100% pass |
| Contract tests | 100% pass |
| Backward compatibility | PASS |
| Database integration | PASS |
| Critical integration failure | 0 |
| Performance baseline | No blocking regression |

## Failure Mode

- API contract mismatch
- Integration test failure
- Database compatibility failure
- Message broker integration failure
- Redis/session integration failure
- Performance regression
- Environment provisioning failure

## Failure Handling

```text
Integration / contract failure
             |
             v
Pipeline blocked
             |
             v
Owning service remediation
             |
             v
New artifact
             |
             v
Integration + contract re-test
```

## Retry / Skip Logic

- Ephemeral infrastructure provisioning failure: one controlled retry.
- Test failure: no automatic skip.
- Contract mismatch: no automatic retry as remediation.
- Flaky test: quarantine workflow plus defect record; production gate remains controlled.

## Evidence

- Pact results
- JUnit results
- Database test logs
- API compatibility report
- Performance baseline
- Namespace lifecycle record

## SLA

**Target: ≤ 20 minutes**

## Estimated duration

**18 minutes**

## Configuration
```text
integration_tests_required = true
contract_tests_required = true
backward_compatibility_required = true
critical_test_failures_allowed = 0
ephemeral_environment = true
```


---

# 9. Stage 6 — Dynamic Analysis & DAST

## Purpose

Assess the running application for exploitable runtime security weaknesses.

## Tooling

**OWASP ZAP**

## Inputs

- Running staging application
- OpenAPI / Swagger specification
- Secure test credentials
- Test endpoints
- Authentication configuration

## Processing

1. Start staging deployment.
2. Import OpenAPI specification.
3. Execute passive scanning.
4. Execute authenticated scanning.
5. Execute active scanning within controlled test scope.
6. Map findings to OWASP Top 10 categories.
7. Apply severity thresholds.
8. Generate DAST report.
9. Route false positives into formal review.

## Outputs

- DAST report
- OWASP finding classification
- Authentication scan result
- API coverage result
- False-positive review record

## Quality Gate

| Control | Threshold |
|---|---:|
| Critical findings | 0 |
| High findings | 0 |
| OWASP Top 10 blocking findings | 0 |
| Authenticated scan | Complete |
| API scan | Complete |

## Failure Mode

- Critical vulnerability
- High vulnerability
- Authentication failure
- Incomplete scan
- API coverage failure
- Scanner infrastructure failure

## Failure Handling

```text
DAST failure
     |
     v
Deployment promotion blocked
     |
     v
Security remediation
     |
     v
DAST re-scan
```

## Retry / Skip Logic

- Scanner infrastructure error: one controlled retry.
- Application vulnerability: no retry as remediation.
- False positive: formal review and evidence required.
- High/Critical skip: prohibited without formal risk acceptance.

## Evidence

- ZAP report
- Scan configuration
- OpenAPI input
- Test credential reference
- Finding disposition
- Risk acceptance record, when applicable

## SLA

**Target: ≤ 15 minutes**

## Estimated duration

**10 minutes**

## Configuration
<<<<<<< HEAD
```text
=======
```yaml

>>>>>>> regular
passive_scan = enabled
active_scan = enabled
authenticated_scan = enabled
critical_block = 0
high_block = 0
<<<<<<< HEAD
=======

>>>>>>> regular
```


---

# 10. Stage 7 — Policy & Compliance Gates

## Purpose

Enforce regulatory, security, supply-chain, infrastructure, access-control, and change-management requirements before production promotion.

## Tooling

- OPA / Rego
- Kyverno
- Cosign
- GitHub Environments
- Kubernetes admission policies
- Immutable audit storage

## Inputs

- SAST result
- DAST result
- Dependency scan
- SBOM
- Image digest
- Image signature
- Kubernetes manifests
- Terraform validation results
- Pull-request approval
- Change record
- Identity and role metadata
- Regulatory mapping

## Compliance gate set

### Gate 1 — SAST

```text
Critical vulnerabilities = 0
High vulnerabilities ≤ 2
Coverage ≥ 80%
```

### Gate 2 — DAST

```text
Critical / High OWASP findings = 0
```

### Gate 3 — Dependency

```text
Critical CVEs = 0
SBOM = present
CVSS ≥ 9.0 = block
```

### Gate 4 — License

```text
GPL / AGPL / SSPL = prohibited
Formal legal exception = required
```

### Gate 5 — Kubernetes Policy

```text
All required OPA / Kyverno policies = PASS
Privileged containers = prohibited
Required security context = present
Resource limits = present
```

### Gate 6 — Infrastructure Policy

```text
Privileged infrastructure = prohibited
Required encryption = enabled
Required network controls = present
Terraform policy checks = PASS
```

### Gate 7 — Image Integrity

```text
Image signature = valid
Registry = approved
Image digest = immutable
SBOM = attached
```

### Gate 8 — Segregation of Duties

```text
Development role ≠ production deployment role
Required approval = present
Production deployment credentials = restricted
```

### Gate 9 — Change Management

```text
Approved change record = present
Rollback plan = present
Test evidence = present
Audit trail = complete
```

## Regulatory Mapping

| Control area | Assessment mapping |
|---|---|
| Change management, testing, approval, rollback | RBI 4.2 |
| Segregation of duties | RBI 4.3 |
| Vulnerability assessment | RBI 5.1 |
| Encryption | RBI 5.4 |
| Audit trail | RBI 6.1 |
| Incident management / continuity | RBI 6.3 |
| Third-party risk / SBOM / licensing | RBI 7.2 |
| Secure software development | PCI-DSS 6.2 |
| Security vulnerability management | PCI-DSS 6.3 |
| Public-facing application protection | PCI-DSS 6.4 |
| Change-management processes | PCI-DSS 6.5 |
| Audit log recording | PCI-DSS 10.2 |
| Penetration testing | PCI-DSS 11.3 |

## Outputs

- Compliance decision
- Policy evaluation report
- Signed artifact evidence
- Audit event
- Regulatory mapping result
- Approval record

## Quality Gate

**All mandatory gates must pass.**

Any hard-blocking failure produces:

```text
COMPLIANCE = FAIL
```

## Failure Mode

- Policy violation
- Missing approval
- Invalid image signature
- Missing SBOM
- Regulatory control failure
- Segregation-of-duties violation
- Missing audit evidence
- Infrastructure policy failure

## Failure Handling

```text
Compliance failure
       |
       v
Production promotion blocked
       |
       +----> Automated ticket
       |
       +----> Audit evidence
       |
       +----> Remediation
       |
       v
Gate re-evaluation
```

## Exception Workflow

```text
Gate failure
    |
    v
Risk assessment
    |
    v
Named approver
    |
    v
Time-bound exception
    |
    v
Automatic expiry
    |
    v
Audit record
```

Exceptions require documented business justification, risk acceptance, named approval, expiration time, and audit evidence.

## Retry / Skip Logic

- Policy engine infrastructure failure: controlled retry.
- Policy violation: no skip.
- Compliance override: formal exception workflow only.
- Direct production bypass: prohibited.

## Evidence

- OPA/Kyverno result
- Cosign signature verification
- SBOM
- Approval record
- Change record
- Regulatory mapping
- Exception record
- Immutable audit event

## SLA

**Target: ≤ 7 minutes**

## Estimated duration

**5 minutes**

## Configuration
```text
signed_image_required = true
sbom_required = true
critical_vulnerability_limit = 0
production_approval_required = true
segregation_of_duties_required = true
plaintext_secrets_allowed = false
audit_evidence_required = true
```


---

# 11. Stage 8 — Deployment & Verification

## Purpose

Release an approved artifact to production without planned downtime, validate production health, manage traffic progressively, and automatically roll back unhealthy releases.

## Tooling

- Kubernetes
- Helm
- Argo CD
- Argo Rollouts
- Istio VirtualService
- Prometheus
- Grafana
- Alertmanager
- PostgreSQL
- pgroll

## Inputs

- Approved container image
- Immutable image digest
- Helm values
- Kubernetes manifests
- Argo CD application state
- Compliance evidence
- Database migration plan
- Traffic policy
- Rollback configuration

## Deployment strategies

### Blue-Green

```text
                    Istio VirtualService
                             |
                  +----------+----------+
                  |                     |
             BLUE v1.4.1          GREEN v1.4.2
              100% traffic            0%
                  |                     |
                  +----------+----------+
                             |
                      Shared PostgreSQL
```

Production traffic remains on the active environment during green deployment and verification.

Traffic switch:

```text
1. Deploy green
2. Wait for readiness
3. Run smoke tests
4. Validate metrics
5. Atomically switch Istio routing
```

Connection draining:

- HTTP requests: 30–60 seconds
- Long-running payment settlement: up to 5 minutes

### Canary

```text
1–2% → 5–10% → 25–50% → 100%
```

Success criteria include error rate, p99 latency, SLO compliance, critical alerts, and comparison against the production baseline.

## Zero-Downtime Database Migration

### Expand

Add backward-compatible schema elements.

### Migrate

Backfill existing records in throttled, idempotent batches.

### Contract

Remove obsolete schema only after all application versions no longer depend on the legacy structure.

Contract execution requires a dedicated approval gate.

## Deployment Verification

Verification includes:

- Kubernetes readiness probes
- Kubernetes liveness probes
- Startup probes
- Pod health
- Image digest consistency
- Configuration consistency
- Smoke tests
- Synthetic payment transaction
- HTTP 5xx rate
- p99 latency
- CPU
- Memory
- Database connection health
- Payment success rate

## Quality Gate

### Blue-Green

```text
Pods healthy = 100%
Readiness = PASS
Smoke tests = PASS
Synthetic payment = PASS
Image digest consistency = PASS
Configuration consistency = PASS
5xx rate = within SLO
p99 latency = within SLO
Database health = PASS
```

### Canary

| Phase | Traffic | Success criteria | Failure action |
|---|---:|---|---|
| Canary | 1–2% | Error rate < 0.1%, p99 < 200 ms | Auto-rollback |
| Early adopter | 5–10% | Error rate < 0.05%, no critical alerts | Auto-rollback |
| Expansion | 25–50% | All SLOs met, no baseline degradation | Auto-rollback |
| Full rollout | 100% | 24-hour SLO compliance | Stable release |

## Rollback Triggers

### Category A — Immediate

Target: **< 60 seconds**

Examples:

- HTTP 5xx > 5% for 60 seconds
- Three consecutive health-check failures
- CrashLoopBackOff
- OOMKill
- Database connection-pool exhaustion
- Synthetic payment failure

### Category B — Escalated

Target: **< 15 minutes**

Examples:

- p99 latency > 2× baseline for 5 minutes
- CPU > 90% for 5 minutes
- Memory > 85% for 5 minutes
- Payment transaction success rate decline > 2%

### Category C — Manual Decision

Examples:

- Gradual degradation
- Customer-impact signal without automated threshold breach
- Downstream dependency instability
- Retroactive compliance concern

## Failure Handling

```text
Deployment
    |
    v
Health / SLO verification
    |
    +-------- PASS --------> Promote
    |
    +-------- FAIL --------> Freeze rollout
                              |
                              v
                         Route traffic
                         to stable version
                              |
                              v
                         Verify recovery
                              |
                              v
                         Notify owners
                              |
                              v
                         Incident record
                              |
                              v
                         Postmortem
```

## Retry / Skip Logic

- Kubernetes transient readiness failure: controlled retry.
- Application health failure: rollback.
- SLO violation: rollback.
- Compliance failure: no deployment retry.
- Production gate bypass: prohibited.
- Rollback verification failure: escalate to incident response.

## Evidence

- Argo CD sync record
- Deployment manifest
- Image digest
- Helm release metadata
- Istio routing state
- Prometheus metrics
- Smoke-test result
- Synthetic transaction result
- Rollback event
- Audit record

## SLA

**Target: ≤ 30 minutes for blue-green production promotion**

## Estimated duration

**20 minutes**

---

# 12. Failure-Path Summary

| Failure area | Pipeline action | Recovery |
|---|---|---|
| Source validation | Block | Commit / approval remediation |
| Build | Block | Code or build remediation |
| Unit test | Block | Test/code remediation |
| SAST | Block | Security remediation |
| Dependency scan | Block | Dependency/image remediation |
| Integration | Block | Service/API remediation |
| DAST | Block | Runtime security remediation |
| Compliance | Hard block | Compliance remediation / formal exception |
| Deployment health | Freeze + rollback | Stable version restoration |
| Database migration | Stop phase / rollback | Migration recovery procedure |

---

# 13. Parallel Execution Design

Parallel execution begins after the build artifact becomes available.

```text
                 Build
                   |
          +--------+--------+
          |        |        |
          v        v        v
       Unit Test  SAST    Trivy/SBOM
          |        |        |
          +--------+--------+
                   |
                   v
        Integration / Contract
                   |
                   v
                 DAST
                   |
                   v
          Compliance Gates
                   |
                   v
          Deployment / Verify
```

The design exceeds the assessment requirement for meaningful parallelisation while preserving mandatory security and compliance ordering.

---

# 14. Pipeline SLA Summary

| Metric | Target |
|---|---:|
| Commit → production | < 2 hours |
| Primary estimated critical path | 77 minutes |
| Developer feedback loop | < 10 minutes |
| Automated steps | > 95% |
| Pipeline parallelisation | > 50% of eligible work |
| Rollback Category A | < 60 seconds |
| Rollback Category B | < 15 minutes |
| Availability | 99.999% |
| Deployment frequency | Multiple per day |
| Change failure rate | < 5% |
| MTTR | < 1 hour |

---

# 15. Evidence Chain

Every production change requires an auditable chain:

```text
Commit SHA
   |
   v
Pull Request
   |
   v
Build ID
   |
   v
Test Reports
   |
   v
SAST Report
   |
   v
SBOM + Vulnerability Report
   |
   v
Contract / Integration Report
   |
   v
DAST Report
   |
   v
Compliance Decision
   |
   v
Approval Record
   |
   v
Image Digest
   |
   v
Deployment Record
   |
   v
Production Verification
```

The evidence chain supports traceability from source change through production deployment.

---

# 16. Assessment Alignment Checklist

| Requirement | Status |
|---|---|
| Eight canonical stages | Complete |
| Tool for every stage | Complete |
| Input for every stage | Complete |
| Output for every stage | Complete |
| Quality gate for every stage | Complete |
| Failure handling for every stage | Complete |
| Estimated timing for every stage | Complete |
| Parallel execution | Complete |
| Commit-to-production < 2 hours | Complete — 77-minute primary path |
| Blue-green deployment | Complete |
| Canary deployment | Complete |
| Automated rollback | Complete |
| Expand-contract migration | Complete |
| RBI mapping | Included |
| PCI-DSS mapping | Included |
| Segregation of duties | Included |
| Audit evidence | Included |

---

# 17. Source Alignment

**Assessment sections used for architecture design:**

- Section A2.1 — CI/CD Pipeline Fundamentals
- Section A2.2 — Eight Canonical Pipeline Stages
- Section A3.1 — Blue-Green Deployments
- Section A3.2 — Canary Deployments
- Section A4 — Compliance & Regulatory Framework
- Section D2 — Mandatory Repository Structure
- Section D3 — Day 2 Pipeline Architecture Design
- Section D3 — Day 3 Detailed Stage Specifications
- Deployment Velocity Audit — commit-to-production and parallelisation targets

**Repository location:**

```text
docs/
└── 01-pipeline-architecture/
    ├── architecture.md
    ├── diagrams/
    │   ├── novapay-pipeline-architecture-v1.drawio
    │   └── novapay-pipeline-architecture-v1.png
    └── stage-details/
        └── pipeline-stage-specifications.md
```
