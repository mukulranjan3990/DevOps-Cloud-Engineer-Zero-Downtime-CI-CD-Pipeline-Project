# Day 13 — OPA Validation Evidence

**Project:** NovaPay Zero-Downtime CI/CD Pipeline  
**Assessment Day:** 13

---

## Policy Files

The project contains three OPA/Rego policy files:

- `pipeline/policies/encryption.rego`
- `pipeline/policies/image-signing.rego`
- `pipeline/policies/kubernetes-security.rego`

---

## Syntax Validation

Command:

```text
opa check ./pipeline/policies

