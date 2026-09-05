terraform {
  required_version = ">= 1.7.0"

  required_providers {
    artifactory = {
      source  = "jfrog/artifactory"
      version = ">= 12.11.0, < 13.0.0"
    }
  }
}

locals {
  common_tags = {
    Project   = "NovaPay"
    ManagedBy = "Terraform"
    Component = "container-registry"
  }
}

resource "artifactory_local_docker_v2_repository" "novapay" {
  key = var.repository_key

  # Keep overwritten image tags available by digest for traceability.
  tag_retention   = var.tag_retention
  max_unique_tags = var.max_unique_tags

  # Reject legacy Docker schema 1 images.
  block_pushing_schema1 = true

  # Production repository policy is controlled by the CI/CD pipeline:
  # SemVer + Git SHA tags, immutable digest promotion, image signing,
  # SBOM/provenance generation, and OPA/Kyverno admission verification.
}
