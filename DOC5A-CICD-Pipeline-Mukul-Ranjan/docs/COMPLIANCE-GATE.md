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


