# Environment Promotion Workflow — NovaPay Digital Bank

**Day 7 | Deliverable 5 | DEV → STAGING → PRE-PROD → PRODUCTION**

## 1. Objective

NovaPay uses a four-environment promotion model for regulated banking CI/CD. The core rule is **same artifact, different configuration**: the same container image produced from the main branch is promoted through all four environments; environment differences are configuration only. fileciteturn6file1

```text
Git Commit
    ↓
Build + Test
    ↓
  DEV
    ↓  automated gates
STAGING
    ↓  quality/security + Tech Lead approval
PRE-PROD
    ↓  UAT + compliance + change controls
PRODUCTION
    ↓
Progressive rollout
```

## 2. Four-Environment Model

| Environment | Purpose | Data Profile | Access Control | Deploy Trigger |
|---|---|---|---|---|
| DEV | Feature development, unit testing | Synthetic/mock only | All developers | Automatic after PR merge |
| STAGING | Integration, DAST, performance | Anonymised production-like | Dev team + QA | Automatic after DEV gates |
| PRE-PROD | UAT, compliance, regulatory verification | Masked production subset | QA + Compliance + DBA | Manual approval after STAGING |
| PRODUCTION | Live customer-facing environment | Real production data | SRE + Release Manager only | Dual approval: RM + SRE Lead |

These environment definitions are specified in the assessment. fileciteturn6file2turn6file3

## 3. Artifact Promotion

```text
              BUILD ONCE
                  ↓
        Signed immutable image
                  ↓
     sha256:<immutable-digest>
                  ↓
   ┌──────┬──────────┬───────────┐
   ↓      ↓          ↓           ↓
  DEV  STAGING    PRE-PROD     PROD
```

The image digest must remain unchanged during promotion. Only configuration changes.

No environment-specific application-code branches are permitted. The assessment explicitly requires the same main branch to produce the same image for every environment. fileciteturn6file1

## 4. DEV → STAGING

### Promotion criteria

- Unit tests: **100% pass**.
- Test failures: **0**.
- Line coverage: **≥80%**.
- Branch coverage: **≥70%**.
- SAST: **0 Critical**, **≤2 High**.
- Artifact signed.
- Artifact pushed to approved registry.
- SemVer tag exists.
- Immutable digest recorded.

These are the assessment-defined criteria. fileciteturn6file2

### Workflow

```text
DEV
 ↓
Unit tests
 ↓
Coverage
 ↓
SAST
 ↓
Signed artifact
 ↓
Registry verification
 ↓
STAGING
```

Promotion is automatic when all gates pass.

**Failure:** block → remediate → rerun.

## 5. STAGING → PRE-PROD

### Promotion criteria

- Integration tests: **100% pass**.
- Consumer-driven contract tests: **PASS**.
- Backward compatibility: **PASS**.
- DAST: **0 Critical/High OWASP Top 10 findings**.
- Performance: **p99 <500 ms at 2× expected production load**.
- Dependency scan: **0 Critical CVEs**.
- SBOM generated and archived.
- Licence compliance passed.
- No GPL/AGPL dependencies.
- **Tech Lead approval**.

These criteria are defined by the assessment. fileciteturn6file2

```text
STAGING
  ↓
Integration + Contract
  ↓
DAST
  ↓
Performance
  ↓
Dependency + SBOM
  ↓
Licence
  ↓
Tech Lead approval
  ↓
PRE-PROD
```

## 6. PRE-PROD → PRODUCTION

### Required criteria

- Product Owner UAT sign-off.
- All regulatory compliance gates passed.
- RBI + PCI-DSS mapping verified.
- Database migration tested with production-scale data.
- Deployment runbook reviewed and signed off by SRE Lead.
- CAB approval OR approved pre-authorised change category.
- Release Manager approval.
- SRE Lead approval.
- Deployment window verified.
- Not during blackout period.
- Not during peak hours.
- On-call engineer confirmed and briefed.

The assessment specifically requires these controls and dual approval. fileciteturn6file1

```text
PRE-PROD
   ↓
UAT PASS
   ↓
Compliance PASS
   ↓
RBI / PCI-DSS verification
   ↓
DB migration PASS
   ↓
Runbook signed
   ↓
Change/CAB approval
   ↓
Release Manager + SRE Lead
   ↓
PRODUCTION
```

## 7. RBAC and Segregation of Duties

| Role | DEV | STAGING | PRE-PROD | PROD |
|---|---|---|---|---|
| Developer | Deploy | Deploy/Test | No direct deploy | No |
| QA | Test | Test | Test/UAT | No |
| Tech Lead | Review | Approve | Review | No sole approval |
| Compliance | Review | Review | Compliance approval | Evidence |
| DBA | No | Test | DB approval | DB support |
| Release Manager | No | No | Review | Approve |
| SRE | No | Observe | Validate | Deploy/Approve with SRE Lead |
| SRE Lead | Review | Review | Review | Approve |

Production requires two independent approvals:

```text
Release Manager
      +
   SRE Lead
      ↓
PRODUCTION APPROVED
```

## 8. Secrets Management

Primary design: **HashiCorp Vault**. AWS Secrets Manager is the assessment-approved alternative. No plaintext secrets may exist in Git, Helm values or Kubernetes manifests. fileciteturn6file1

```text
Application
    ↓
Workload Identity
    ↓
Vault
    ↓
Controlled secret
    ↓
Application
```

### Rotation

| Secret | Rotation |
|---|---:|
| Database passwords | 90 days |
| API keys | 30 days |

Never store secrets in:

```text
Git
values.yaml
values-production.yaml
Kubernetes manifests
Dockerfiles
Source code
```

## 9. Configuration Hierarchy

Required hierarchy:

```text
Base Configuration
       ↓
Environment Override
       ↓
Service Override
```

Example:

```text
helm/
└── novapay/
    ├── values.yaml
    ├── values-dev.yaml
    ├── values-staging.yaml
    ├── values-preprod.yaml
    ├── values-production.yaml
    └── templates/
```

The assessment explicitly defines this base → environment → service hierarchy. fileciteturn6file1

### Example

```yaml
# values.yaml
image:
  repository: registry.example.com/novapay/payment

security:
  runAsNonRoot: true
```

```yaml
# values-staging.yaml
environment: staging
replicaCount: 2
```

```yaml
# values-production.yaml
environment: production
replicaCount: 6
```

The application image remains identical.

## 10. Feature Flags

Use an environment-aware feature flag system similar to LaunchDarkly.

New code can be deployed everywhere while the production feature remains disabled until ready. fileciteturn6file1

```text
Deploy code
   ↓
Feature OFF in PROD
   ↓
Enable gradually
   ↓
1%
 ↓
10%
 ↓
50%
 ↓
100%
```

At every step monitor:

- Error rate.
- p99 latency.
- Payment success.
- Application health.
- Database health.

If unhealthy:

```text
Feature flag OFF
      ↓
Stable behavior restored
```

## 11. Configuration Drift Detection

Use **Argo CD** to compare Git-declared state with live Kubernetes state.

The assessment specifies a **3-minute** drift comparison interval, Slack notification, and optional auto-sync. fileciteturn6file1

```text
Git Desired State
       ↓
    Argo CD
       ↓
Live Cluster State
       ↓
    Compare
    /     \
Same     Drift
 |         |
PASS      Alert
           ↓
      Optional sync
```

Unauthorized production drift must trigger SRE investigation and an audit/change record.

## 12. Data Management

| Environment | Data |
|---|---|
| DEV | Synthetic/mock |
| STAGING | Anonymised production-like |
| PRE-PROD | Masked production subset |
| PROD | Real production |

```text
Synthetic
   ↓
 DEV

Anonymised
   ↓
 STAGING

Masked subset
   ↓
 PRE-PROD

Real data
   ↓
 PROD
```

Production data must not simply be copied into non-production environments.

Sensitive fields should be masked/anonymised/tokenised as required.

## 13. Configuration Change Control

Configuration changes must use the same CI/CD controls as code.

This includes:

- WAF rules.
- Feature flags.
- Routing rules.
- Helm configuration.
- Environment variables.
- Infrastructure configuration.

The assessment's case-study lessons explicitly require configuration changes to go through the same CI/CD pipeline as code. fileciteturn6file5

```text
Config Change
     ↓
Git PR
     ↓
Review
     ↓
Security / Compliance Gates
     ↓
Environment Promotion
```

## 14. Promotion Failure Rules

### DEV → STAGING

Any gate fails:

```text
BLOCK
 ↓
Fix
 ↓
Rerun
```

### STAGING → PRE-PROD

Security/integration/performance/dependency failure:

```text
BLOCK
 ↓
Remediate
 ↓
Retest
 ↓
Approve
```

### PRE-PROD → PROD

Missing UAT, compliance, change approval or dual approval:

```text
BLOCK PRODUCTION
       ↓
Complete missing control
       ↓
Re-evaluate
```

Compliance failures cannot be skipped.

## 15. Production Rollout

After production approval, use controlled blue-green or canary rollout.

Canary model:

```text
1–2%
  ↓
5–10%
  ↓
25–50%
  ↓
100%
```

Feature flags may use the assessment-defined:

```text
1% → 10% → 50% → 100%
```

For blue-green:

```text
Blue = current stable
Green = new release

Deploy Green
    ↓
Readiness
    ↓
Smoke tests
    ↓
Synthetic payment
    ↓
Metric verification
    ↓
Traffic switch
```

## 16. Audit Trail

Every promotion records:

```json
{
  "promotion_id": "<unique-id>",
  "artifact_digest": "sha256:<digest>",
  "git_sha": "<commit-sha>",
  "source_environment": "pre-prod",
  "target_environment": "production",
  "requested_by": "<identity>",
  "approved_by": [
    "<release-manager>",
    "<sre-lead>"
  ],
  "change_id": "<change-ticket>",
  "timestamp": "<timestamp>",
  "result": "PASS"
}
```

Evidence:

- Artifact digest.
- Git SHA.
- Test reports.
- Security reports.
- Compliance results.
- Approval records.
- Configuration version.
- Deployment timestamp.
- Argo CD sync record.
- Drift status.

## 17. End-to-End Workflow

```text
Developer
   ↓
Git PR
   ↓
Build + Tests
   ↓
DEV
   ↓
Automated quality/security gates
   ↓
STAGING
   ↓
Integration + Contract + DAST + Performance
   ↓
Tech Lead approval
   ↓
PRE-PROD
   ↓
UAT + Compliance + DB migration validation
   ↓
Change/CAB + RM + SRE Lead approvals
   ↓
PRODUCTION
   ↓
Blue-Green / Canary
   ↓
Progressive rollout
   ↓
100%
```

## 18. Promotion Summary

| Transition | Trigger | Approval |
|---|---|---|
| DEV → STAGING | Automatic after DEV gates | None if all gates pass |
| STAGING → PRE-PROD | Manual after STAGING gates | Tech Lead |
| PRE-PROD → PROD | Controlled production release | Release Manager + SRE Lead |

## 19. Day 7 Completion Checklist

- [x] Four-environment model.
- [x] Purpose/data/access/trigger for each environment.
- [x] DEV → STAGING criteria.
- [x] STAGING → PRE-PROD criteria.
- [x] PRE-PROD → PROD criteria.
- [x] Named roles and RBAC.
- [x] Dual production approval.
- [x] HashiCorp Vault.
- [x] Secret rotation.
- [x] Feature flags.
- [x] Configuration drift detection.
- [x] Base → environment → service hierarchy.
- [x] Same artifact, different config.
- [x] No environment-specific branches.
- [x] Synthetic/anonymised/masked/production data strategy.
- [x] Audit trail.
- [x] Configuration changes through CI/CD.

## 20. Final Rule

> **Build once and promote the same immutable artifact through DEV → STAGING → PRE-PROD → PRODUCTION. Change configuration, not application code. Production promotion requires all gates, required approvals, valid change controls and segregation of duties.**

This document implements the assessment's **Day 7 — Environment Promotion Workflow / Deliverable 5**. fileciteturn6file0turn6file1turn6file2




---

## Cross-Deliverable References

- [Deliverable 1 — Pipeline Architecture](../01-pipeline-architecture/architecture.md)
- [Deliverable 2 — Deployment Strategies](../02-deployment-strategies/deployment-strategy.md)
- [Deliverable 3 — Compliance Gates](../03-compliance-gates/compliance-gates.md)
- [Deliverable 4 — Database Migration](../04-database-migration/database-migration-strategy.md)
- [Deliverable 6 — Rollback Specification](../06-rollback-specification/rollback-specification.md)
- [Deliverable 8 — Observability](../08-observability/observability-strategy.md)
## AI Assistance & Attribution

> **AI Assistance:** This document was developed with AI-assisted drafting and analysis. The final technical decisions, thresholds, architecture alignment, implementation details, validation, and submission responsibility remain with the project author. The primary governing source for this deliverable is the NovaPay Zero-Downtime CI/CD Pipeline Assessment provided for this project.
