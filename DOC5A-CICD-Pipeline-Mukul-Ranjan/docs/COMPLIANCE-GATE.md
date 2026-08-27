# NovaPay Compliance Gates

## Purpose

The purpose of compliance gates is to automatically check
security, quality, regulatory and infrastructure requirements
before allowing a deployment to continue.

A failed mandatory gate should stop the deployment.

The pipeline should also create an audit record showing:

- What was checked
- The result
- The threshold
- The failure reason
- Any approved exception
- Who approved it
- When it was approved

---


# Compliance Gate Flow

```text
                    NOVAPAY CI/CD PIPELINE
                             |
                             v
                       Source Code
                             |
                             v
                         Build/Test
                             |
                             v
                     +---------------+
                     |     SAST      |
                     | Code Security |
                     +---------------+
                             |
                         PASS?
                        /     \
                      YES      NO
                       |        |
                       v        v
                 Dependency    STOP
                    Scan        |
                       |         |
                       v         v
                   Licence    Remediation
                    Check
                       |
                       v
                      DAST
                       |
                       v
                 Policy Check
                       |
                       v
              Infrastructure Check
                       |
                       v
                Compliance Gates
                       |
                       v
                Production Approval
                       |
                       v
                    Deploy
                       |
                       v
                 Health Check
                       |
                 +-----+-----+
                 |           |
              Healthy     Unhealthy
                 |           |
                 v           v
              Continue     Rollback
                 |           |
                 v           v
             Production   Recovery

```

---

## Gate 1 - SAST
> What does it check?

> Checks source code for security vulnerabilities and code-quality problems.

**Example Threshold**

* Critical vulnerabilities: 0
* High vulnerabilities: <= 2
* Coverage: >= 80%

**PASS**
> Pipeline continues.

**FAIL**
> Pipeline is blocked.

#### What to do after failure?

> Developer fixes the reported problems and runs the pipeline again.

+ Regulatory Mapping
+ RBI 5.1
+ PCI-DSS 6.2

#### Tool
> SonarQube

---

## Gate 2 - Dependency / Container Scan
> What does it check?

> Checks application dependencies and container images for known security vulnerabilities.
 

**Example Threshold**

* No Critical vulnerabilities
* High vulnerabilities must remain within the approved threshold

**PASS** 
> Pipeline continues.

**FAIL**
> Deployment is blocked.

#### What to do after failure?

> Upgrade, replace or remove the vulnerable dependency/image.

+ Regulatory Mapping
+ RBI 5.1
+ PCI-DSS 6.3

#### Tool
> Trivy

---

## Gate 3 - Licence Compliance
> What does it check?

> Checks whether third-party and open-source dependencies comply
> with the project's allowed licence policy.

**PASS**
> All dependencies comply with the approved licence policy.

**FAIL**
> Deployment is blocked or sent for an approved exception.

#### What to do after failure?

> Replace the dependency or obtain the required approval.

+ Regulatory Mapping
+ RBI 7.2

#### Tools
> FOSSA/Scancode

---

## Gate 4 - DAST
> What does it check?

> Tests the running application for security vulnerabilities.

**PASS**
> No unacceptable security findings.

**FAIL**
> Deployment is blocked or the issue is sent for remediation.

#### What to do after failure?

> Fix the application vulnerability and repeat the security test.

+ Regulatory Mapping
+ RBI 5.1
+ PCI-DSS 6.4
+ PCI-DSS 11.3

#### Tool
> OWASP ZAP

---

## Gate 5 - Policy Compliance
> What does it check?

> Checks whether Kubernetes/deployment resources follow NovaPay's
> security policies.

**Example policies:**

* Privileged containers are not allowed
* Required security settings must be present
* Required labels must exist
* Insecure configurations are rejected
* Tool

OPA / Rego or Kyverno.

**PASS**
> Resources follow the required policies.

**FAIL**
> The deployment is rejected.

#### What to do after failure?

> repeat it before check the mapping.


+ Regulatory Mapping
+ RBI 4.2
+ RBI 5.4
+ PCI-DSS security/change controls

#### Tool
> OPA/Kyver no

---

## Gate 6 - Infrastructure Compliance
> What does it check?

> Checks infrastructure configuration for insecure settings.

**Examples:**

* Insecure network configuration
* Missing encryption
* Incorrect access configuration
* Unsafe cloud configuration

**PASS**
> Infrastructure follows the approved baseline.

**FAIL**
> Infrastructure deployment is blocked.

#### What to do after failure?

> Fix the infrastructure configuration and run the checks again.

+ Regulatory Mapping
+ RBI 5.4
+ RBI 4.2

#### Tools
> checkov/Terrraform

---

## Additional Compliance Controls

**Audit Gate**

> Every important pipeline action should create an audit record.

#### Record:

* Actor
* Commit SHA
* Build ID
* Artifact version
* Security results
* Approval
* Deployment time
* Deployment environment
* Final result


---
---

## What Happens When a Gate Fails?
```text


                Gate
                  |
                  v
               FAIL
                  |
          +-------+-------+
          |               |
          v               v
       Can Fix?      Exception Needed?
          |               |
         YES              YES
          |               |
          v               v
        Fix          Request Exception
          |               |
          v               v
       Re-run       Authorized Approval
          |               |
          +-------+-------+
                  |
                  v
              Gate Pass
                  |
                  v
               Continue


```

The assessment specifically requires **6+ automated compliance gates**, each with thresholds, remediation, exception handling, 
audit records and regulatory mapping. :contentReference[oaicite:3]{index=3} It also requires **3+ OPA/Rego policies** and a 
compliance-gate orchestration diagram. :contentReference[oaicite:4]{index=4}

---

## Your A4 folder will now look like this

```text
DOC5A-CICD-Pipeline-NovaPay/
│
├── docs/
│   ├── research-notes.md
│   ├── RBI-RULES.md
│   ├── PCI-DSS-RULES.md
│   └── COMPLIANCE-GATE.md
│
├── .github/
│   └── workflows/
│
└── ...

RBI-RULES.md
    ↓
"What RBI rules do we need to follow?"

PCI-DSS-RULES.md
    ↓
"What PCI-DSS rules do we need to follow?"

COMPLIANCE-GATE.md
    ↓
"How do we turn those rules into automatic
checks inside our CI/CD pipeline?"



```
### Compliance Gate Table Information.


| Gate | Tool | Threshold | On Failure | Exception Process |
| :--- | :--- | :--- | :--- | :--- |
| **SAST** | SonarQube | 0 Critical, ≤2 High, ≥80% coverage | Pipeline blocked, auto-ticket | CISO approval within 24h |
| **DAST** | OWASP ZAP | 0 Critical/High from OWASP Top 10 | Pipeline blocked | Risk acceptance form + TRC |
| **Dependency** | Trivy | 0 Critical CVE, SBOM generated | Pipeline blocked if CVSS ≥9.0 | 72h remediation window |
| **License** | FOSSA / Scancode | No GPL/AGPL/SSPL dependencies | Legal review triggered | Legal team sign-off |
| **Policy** | OPA / Kyverno | All K8s policies pass | Deployment rejected | Dual approval override |
| **Infra** | Checkov / Terraform | No privileged containers, limits set | PR blocked | Tech Lead exemption |
