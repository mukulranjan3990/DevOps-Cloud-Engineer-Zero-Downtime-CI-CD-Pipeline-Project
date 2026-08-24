# Research Notes

## Day 1 - Research & Foundation

### 5. NovaPay Scenario

Current problems:
- Manual SSH deployments
- 4.5-hour MTTR
- Fortnightly deployments
- No automated compliance scanning
- 17 outstanding RBI audit non-conformances


######                  A1 - DevOps in Regulated Banking              #######

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

###### some important questioni of the day 1 #######

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


##### next steps: #####

A2 = HOW the CI/CD pipeline works
A3 = HOW to deploy without downtime
A4 = HOW to enforce compliance
A5 = HOW to measure reliability/performance
A6 = HOW to operate and respond to incidents
A7 = WHERE to learn these technologies


######                    A2 - CI/CD Pipeline Fundamentals                    ######


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