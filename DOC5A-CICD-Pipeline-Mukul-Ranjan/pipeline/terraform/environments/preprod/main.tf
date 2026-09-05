terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.100, < 6.0"
    }
    artifactory = {
      source  = "jfrog/artifactory"
      version = ">= 12.11.0, < 13.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Credentials are supplied through CI/CD secret management.
# Never store AWS/JFrog credentials in Git or terraform.tfvars.
provider "artifactory" {}

locals {
  environment = "preprod"

  common_tags = merge(
    {
      Project     = "NovaPay"
      Environment = local.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

module "networking" {
  source = "../../modules/networking"

  name                 = var.name_prefix
  cluster_name         = var.cluster_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = local.common_tags
}

module "kubernetes_cluster" {
  source = "../../modules/kubernetes-cluster"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  node_group_name             = var.node_group_name
  node_instance_types         = var.node_instance_types
  node_capacity_type          = "ON_DEMAND"
  node_min_size               = var.node_min_size
  node_desired_size           = var.node_desired_size
  node_max_size               = var.node_max_size
  node_disk_size              = var.node_disk_size
  node_update_max_unavailable = 1

  enable_encryption = true

  tags = local.common_tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix = var.name_prefix
  environment = local.environment

  application_log_retention_days = var.application_log_retention_days
  audit_log_retention_days       = var.audit_log_retention_days
  alert_email                    = var.alert_email

  tags = local.common_tags
}

# JFrog Artifactory is the shared artifact registry.
# Pre-production consumes the same immutable artifact promoted through
# Dev and Staging; it does not rebuild the application image.
#
# The Kubernetes blue/green deployment, Istio traffic shifting,
# long-running transaction draining, rollback, SLO checks, and approval
# workflow are intentionally handled by the Helm/ArgoCD/Istio layers.
