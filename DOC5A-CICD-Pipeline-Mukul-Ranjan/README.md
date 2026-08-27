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


### Actuall git repo structure

Project1A-DevOps&CloudEngineer-YourName-YourName/
│
├── [README.md](README.md)
├── [ERRATA.md](ERRATA.md)
│
├── [docs/](docs)
│   ├── [research-notes.md](reasearch-notes.md)
│   │
│   ├── [01-pipeline-architecture/](docs/01-pipeline-architecture)
│   │   ├── [architecture.md](docs/01-pipeline-architecture/architecture.md)
│   │   └── [diagrams/](docs/01-pipeline-architecture/diagrams)
│   │   └── [stage-details/](docs/01-pipeline-architecture/stage-details)
|   |    
│   ├── [02-deployment-strategies/](docs/02-deployment-strategies)
│   │
│   ├── [03-compliance-gates/](docs/03-compliance-gates)
│   │
│   ├── [04-database-migration/](docs/04-database-migration/)
│   │
│   ├── [05-environment-promotion/](docs/05-environment-promotion/)
│   │
│   ├── [06-rollback-specification/](docs/06-rollback-specification/)
│   │
│   ├── [07-runbook-playbook/](docs/07-runbook-playbook/)
│   │
│   └── [08-observability/](docs/08-observability/)
│
├── [pipeline/](pipeline)
│   ├── [jenkins/](pipeline/jenkins/)
│   │   └── [Jenkinsfile](pipeline/jenkins/Jenkinsfile)
|   |
│   ├── [.github/](pipeline/.github/)
|   |   └── [workflows](pipeline/.github/workflows/)
│   │
│   ├── [terraform/](pipeline/terraform/)
│   │   ├── [modules/](pipeline/terraform/modules/)
│   │   ├── [dev/](pipeline/terraform/dev/)
│   │   ├── [staging/](pipeline/terraform/staging/)
│   │   └── [production/](pipeline/terraform/production/)
│   │
│   ├── [kubernetes/](pipeline/kubernetes/)
│   │   ├── [base/](pipeline/kubernetes/base/)
│   │   └── [overlays/](pipeline/kubernetes/overlays/)
│   │
│   ├── [argocd/](pipeline/argocd/)
│   │   └── [applications/](pipeline/argocd/applications/)
│   │
│   ├── [docker/](pipeline/docker/)
│   │   └── [Dockerfile](pipeline/docker/Dockerfile)
│   │
│   ├── [ansible/](pipeline/ansible/)
│   │
│   └── [scripts/](pipeline/scripts/)
│
├── [dashboards/](dashboards)
│   └── [grafana/](dashboards/grafana/)
│
└── [runbooks/](runbooks)
    ├── deployment-runbook.md
    └── incident-playbook.md
