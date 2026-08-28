# NovaPay Zero-Downtime CI/CD Pipeline

## Project Information

+ Name: Mukul Ranjan
+ Track: DevOps & Cloud Engineer
+ Project: Zero-Downtime CI/CD Pipeline with Compliance Gates.
+ Application: NovaPay Digital Bank
+ Duration: 15 Days

## Project Overview

This project designs a production-grade, zero-downtime CI/CD
pipeline for NovaPay Digital Bank.


## Architecture

[Placeholder]

## Deliverables

1. Pipeline Architecture
2. Deployment Strategies
3. Compliance Gates
4. Database Migration
5. Environment Promotion
6. Rollback Specification
7. Runbook & Playbook
8. Observability

## Navigation

- [Pipeline Architecture](docs/01-pipeline-architecture/)
- [Deployment Strategies](docs/02-deployment-strategies/)
- [Compliance Gates](docs/03-compliance-gates/)
- [Database Migration](docs/04-database-migration/)
- [Environment Promotion](docs/05-environment-promotion/)
- [Rollback Specification](docs/06-rollback-specification/)
- [Runbook & Playbook](docs/07-runbook-playbook/)
- [Observability](docs/08-observability/)



## Refrence git repo structure 
```
Project1A-DevOps&CloudEngineer-YourName
│
├── README.md
│
├── architecture/
│   ├── architecture.md
│   └── architecture.png
│
├── pipeline/
│   ├── github-actions.yml
│   ├── policies/
│   ├── terraform/
│   ├── helm/
│   └── argocd/
│
├── security/
│   ├── sast.md
│   ├── dast.md
│   ├── dependency-scanning.md
│   └── sbom.md
│
├── database/
│   ├── migration-strategy.md
│   └── compatibility-matrix.md
│
├── deployment/
│   ├── blue-green.md
│   ├── canary.md
│   └── rollback.md
│
├── compliance/
│   ├── rbi-mapping.md
│   ├── pci-dss-mapping.md
│   └── compliance-gates.md
│
├── runbooks/
│   ├── deployment-runbook.md
│   └── incident-playbook.md
│
├── observability/
│   ├── metrics.md
│   ├── dashboards/
│   └── alerts/
│
├── incident/
│   ├── simulation.md
│   └── postmortem.md
│
├── trc/
│   └── presentation.pdf
│
└── evidence/
    └── screenshots/


```




### Actual Project Repository Structure

<pre>
Project1A-DevOps&CloudEngineer-YourName/
│
├── <a href="README.md">README.md</a>
├── <a href="ERRATA.md">ERRATA.md</a>
│
├── <a href="docs">docs/</a>
│   ├── <a href="docs/research-notes.md">research-notes.md</a>
│   ├── <a href="docs/RBI-IT-RISK-SECTION-4-7.md">RBI-IT-RISK-SECTION-4-7.md</a>
│   ├── <a href="docs/PCI-DSS-REQUIREMENTS.md">PCI-DSS-REQUIREMENTS.md</a>
|   |
│   │
│   ├── <a href="docs/01-pipeline-architecture">01-pipeline-architecture/</a>
│   │   ├── <a href="docs/01-pipeline-architecture/architecture.md">architecture.md</a>
|   |   | 
│   │   ├── <a href="docs/01-pipeline-architecture/diagrams">diagrams/</a>
|   |   |   ├── <a href="novapay-pipeline-architecture-v1.drawio">novapay-pipeline-architecture-v1.drawio</a>
|   |   |   └── <a href="novapay-pipeline-architecture-v1.png">novapay-pipeline-architecture-v1.png</a>
|   |   |    
│   │   └── <a href="docs/01-pipeline-architecture/stage-details">stage-details/</a>
|   |       └── <a href="pipeline-stage-specifications.md">pipeline-stage-specifications.md</a>
│   │
│   ├── <a href="docs/02-deployment-strategies">02-deployment-strategies/</a>
│   ├── <a href="docs/03-compliance-gates">03-compliance-gates/</a>
│   |   └── <a href="docs/COMPLIANCE-GATE.md">COMPLIANCE-GATE.md</a>
|   |
│   ├── <a href="docs/04-database-migration">04-database-migration/</a>
│   ├── <a href="docs/05-environment-promotion">05-environment-promotion/</a>
│   ├── <a href="docs/06-rollback-specification">06-rollback-specification/</a>
│   ├── <a href="docs/07-runbook-playbook">07-runbook-playbook/</a>
│   └── <a href="docs/08-observability">08-observability/</a>
│
├── <a href="pipeline">pipeline/</a>
│   ├── <a href="pipeline/jenkins">jenkins/</a>
│   │   └── <a href="pipeline/jenkins/Jenkinsfile">Jenkinsfile</a>
│   │
│   ├── <a href="pipeline/.github">.github/</a>
│   │   └── <a href="pipeline/.github/workflows">workflows/</a>
│   │
│   ├── <a href="pipeline/terraform">terraform/</a>
│   │   ├── <a href="pipeline/terraform/modules">modules/</a>
│   │   ├── <a href="pipeline/terraform/dev">dev/</a>
│   │   ├── <a href="pipeline/terraform/staging">staging/</a>
│   │   └── <a href="pipeline/terraform/production">production/</a>
│   │
│   ├── <a href="pipeline/kubernetes">kubernetes/</a>
│   │   ├── <a href="pipeline/kubernetes/base">base/</a>
│   │   └── <a href="pipeline/kubernetes/overlays">overlays/</a>
│   │
│   ├── <a href="pipeline/argocd">argocd/</a>
│   │   └── <a href="pipeline/argocd/applications">applications/</a>
│   │
│   ├── <a href="pipeline/docker">docker/</a>
│   │   └── <a href="pipeline/docker/Dockerfile">Dockerfile</a>
│   │
│   ├── <a href="pipeline/ansible">ansible/</a>
│   └── <a href="pipeline/scripts">scripts/</a>
│
├── <a href="dashboards">dashboards/</a>
│   └── <a href="dashboards/grafana">grafana/</a>
│
└── <a href="runbooks">runbooks/</a>
    ├── <a href="runbooks/deployment-runbook.md">deployment-runbook.md</a>
    └── <a href="runbooks/incident-playbook.md">incident-playbook.md</a>
</pre>
