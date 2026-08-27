# Research Notes

## Day 1 - Research & Foundation

### 5. NovaPay Scenario

Current problems:
- Manual SSH deployments
- 4.5-hour MTTR
- Fortnightly deployments
- No automated compliance scanning
- 17 outstanding RBI audit non-conformances


### A1 - DevOps in Regulated Banking            

## Key Concept

Banking DevOps must balance deployment velocity with
security, regulatory compliance, auditability and availability.

## NovaPay Context

NovaPay is a fictional RBI-licensed digital bank.
The CI/CD platform must support fast releases while
maintaining regulatory controls.

## Key Requirements

- RBI technology risk compliance [open-from-here-to-know-about-it](RBI-IT-RISK-SECTION-4-7.md)
- PCI-DSS security requirements [open-from-here-to-check-it](PCI-DSS-REQUIREMENTS.md)
- Segregation of duties
- Complete audit trail
- Automated security testing
- Zero-downtime deployment
- Automated rollback
- Five-nines availability
- Rapid incident detection and recovery

---

# [RBI Rules - NovaPay CI/CD Compliance](RBI-IT-RISK-SECTION-4-7.md#rbi-rules---novapay-cicd-compliance-1)
   
   1. [RBI 4.2 - CHANGE MANAGMENT](RBI-IT-RISK-SECTION-4-7.md#rbi-42---change-management)
   2. [RBI 4.3 - SEGREGATION OF DUTIES](RBI-IT-RISK-SECTION-4-7.md#rbi-43---segregation-of-duties)
   3. [RBI 5.1 - VULNERABILITY ASSESSMENT](RBI-IT-RISK-SECTION-4-7.md#rbi-51---vulnerability-assessment)
   4. [RBI 5.4 - ENCRYPTION](RBI-IT-RISK-SECTION-4-7.md#rbi-54---encryption)
   5. [RBI 6.1 - AUDIT TRAIL](RBI-IT-RISK-SECTION-4-7.md#rbi-61---audit-trail)
   6. [RBI 6.3 - INCIDENT MANAGMENT & BUISNESS CONTINUITY](RBI-IT-RISK-SECTION-4-7.md#rbi-63---incident-management--business-continuity)
   7. [RBI 7.2 - THIRD-PARTY RISK](RBI-IT-RISK-SECTION-4-7.md#rbi-72---third-party-risk)

---

# [PCI-DSS Rules - NovaPay CI/CD Compliance](PCI-DSS-REQUIREMENTS.md#pci-dss-rules---novapay-cicd-compliance-1)
   
   1. [PCI-DSS 6.2 - SECURE SOFTWARE](PCI-DSS-REQUIREMENTS.md#pci-dss-62---secure-software)
   2. [PCI-DSS 6.3 - VULNERABILITIES](PCI-DSS-REQUIREMENTS.md#pci-dss-63---vulnerabilities)
   3. [PCI-DSS 6.4 - PUBLIC WEB APPLICATION PROTECTION](PCI-DSS-REQUIREMENTS.md#pci-dss-64---public-web-application-security)
   4. [PCI-DSS 6.5 - CHANGE MANAGMENT](PCI-DSS-REQUIREMENTS.md#pci-dss-65---change-management)
   5. [PCI-DSS 10.2 - AUDIT LOG](PCI-DSS-REQUIREMENTS.md#pci-dss-102---audit-logs)
   6. [PCI-DSS 11.3 - PENETRATION TESTING](PCI-DSS-REQUIREMENTS.md#pci-dss-113---penetration-testing)
   7. [PCI-DSS 12.6 - SECURITY AWARENESS](PCI-DSS-REQUIREMENTS.md#pci-dss-126---security-awareness)

---

# [NovaPay Compliance Gates](COMPLIANCE-GATE.md)


---
---

## Why Zero Downtime Matters

Payment systems operate continuously.
Even short outages can affect large numbers of
transactions and create regulatory/business impact.

## DevOps Objective

Build a CI/CD platform that allows NovaPay to:
1. Deploy frequently
2. Detect security problems automatically
3. Enforce compliance gates
4. Deploy without downtime
5. Roll back automatically when required
6. Maintain complete deployment evidence

### some important questioni of the day 1 

1. Why does NovaPay need a special CI/CD pipeline instead of a normal DevOps pipeline?
   
--> In a normal software company, the priority might be:
    Developer → Build → Test → Deploy → Done
    
    But in a bank, you have two competing requirements:
    Developer writes code
        ↓
    Code review
        ↓
    Automated tests
        ↓
    Build
        ↓
    Deploy

    Fast deployment + Security + Compliance + Auditability + Zero downtime

2. Why a 30-second outage matters

--> The document says that even a 30-second outage during peak UPI periods can affect millions of transactions and potentially
    trigger regulatory scrutiny.

Peak periods mentioned are approximately:    10 AM – 12 PM & 5 PM – 8 PM

So deployment strategy cannot be:

Stop application
      ↓
Deploy new version
      ↓
Start application

instead:

Current version → New version
      ↓
Blue-Green / Canary
      ↓
Health verification
      ↓
Traffic gradually moved
      ↓
Rollback if unhealthy


## next steps: 

A2 = HOW the CI/CD pipeline works
A3 = HOW to deploy without downtime
A4 = HOW to enforce compliance
A5 = HOW to measure reliability/performance
A6 = HOW to operate and respond to incidents
A7 = WHERE to learn these technologies


###    A2 - CI/CD Pipeline Fundamentals                   


## 1. What is CI/CD?

CI/CD is an automated process that takes code from the developer's
repository through build, testing, security checks, compliance checks,
and deployment.

For NovaPay, the CI/CD pipeline also provides an audit trail so that
each code change can be traced from commit to production.

## 2. Why NovaPay Needs CI/CD

NovaPay currently uses manual deployments.

The CI/CD pipeline will help NovaPay:
- automate deployments
- test code automatically
- detect security problems
- enforce quality and compliance checks
- reduce human errors
- provide traceability
- support faster releases

## 3. Eight CI/CD Pipeline Stages

### Stage 1 - Source Control & Trigger
Code is stored in GitHub.
Pipeline starts when developers create a pull request,
push code, or create a release/tag.

Important controls:
- branch protection
- code review
- signed commits

### Stage 2 - Build & Compilation
Build the application and run unit tests.
The build should be reproducible and use locked dependencies.

### Stage 3 - Static Analysis & SAST
Check source code for bugs, security problems and code quality issues.

Possible tool:
- SonarQube

### Stage 4 - Dependency & Container Scanning
Check application dependencies and Docker images for vulnerabilities.

Possible tools:
- Trivy
- Grype

Generate an SBOM for software component tracking.

### Stage 5 - Integration & Contract Testing
Check that different services work correctly together.
Also verify API compatibility.

Possible tool:
- Pact

### Stage 6 - Dynamic Analysis & DAST
Test the running application for security vulnerabilities.

Possible tool:
- OWASP ZAP

### Stage 7 - Policy & Compliance Gates
Check that the deployment follows security and banking policies.

Possible tools:
- OPA
- Kyverno

The pipeline should block deployments when mandatory policies fail.

### Stage 8 - Deployment & Verification
Deploy the application and verify that it is working correctly.

The deployment should support:
- blue-green deployment
- canary deployment
- health checks
- smoke tests
- automated rollback


--- 

## 4. Branching Strategy

NovaPay should use a simple branching approach such as
Trunk-Based Development.

Important rules:
- developers should not directly push to main
- pull requests require code review
- branch protection must be enabled
- commits should be signed
- hotfixes must still pass security and compliance gates

## 5. Artifact Versioning

Every build artifact must have a unique version.

Use Semantic Versioning:

MAJOR.MINOR.PATCH+build_metadata

Container images should contain:
- version
- Git SHA

Do not use "latest" for production images.

Images should also be signed so that NovaPay can verify where
the deployed image came from.

## 6. Main Goal for NovaPay

The final CI/CD pipeline should provide:

Code
  ↓
Build
  ↓
Test
  ↓
Security
  ↓
Compliance
  ↓
Deploy
  ↓
Verify
  ↓
Production

The pipeline should stop when an important quality, security,
or compliance check fails.



---
---

## SECTION A7: LEARNING RESOURCES (ALL FREE)
--- 

### Video Resources

* YouTube: “CI/CD Pipeline Tutorial for Beginners” by TechWorld with Nana (2.5 hours)
* YouTube: “Kubernetes Deployment Strategies Explained” by Viktor Farcic (45 min)
* YouTube: “Blue-Green Deployments on Kubernetes with Istio” by Google Cloud (30
min)
* YouTube: “DevSecOps Full Course” by freeCodeCamp (6 hours)
* YouTube: “Prometheus and Grafana Tutorial” by TechWorld with Nana (3 hours)
* YouTube: “GitHub Actions Full Course” by freeCodeCamp (5 hours)
* YouTube: “Terraform Full Course” by HashiCorp (4 hours)
* YouTube: “OPA / Rego Policy Language Tutorial” by Styra (2 hours)

---

### Documentation & Reading

* DORA State of DevOps Report 2024 - https://dora.dev
* Accelerate (book) by Nicole Forsgren, Jez Humble, Gene Kim
* The Phoenix Project (book) by Gene Kim, Kevin Behr, George Spafford
* GitHub Actions documentation - https://docs.github.com/en/actions
* ArgoCD documentation - https://argo-cd.readthedocs.io
* OPA Policy Language (Rego) - https://www.openpolicyagent.org/docs
* PCI-DSS v4.0 Quick Reference - https://www.pcisecuritystandards.org
* RBI Master Direction on IT Governance - https://rbi.org.in
* OWASP Top 10 (2021) - https://owasp.org/Top10/
* Kubernetes documentation - https://kubernetes.io/docs

---

### Hands-On Practice

* Killercoda Kubernetes scenarios (free, browser-based) - https://killercoda.com
* GitHub Skills learning paths - https://skills.github.com
* Play with Kubernetes - https://labs.play-with-k8s.com (free 4-hour sessions)
* SonarCloud (free for open-source) - https://sonarcloud.io
* OWASP WebGoat (practice DAST scanning) - https://owasp.org/www-project-webgoat/