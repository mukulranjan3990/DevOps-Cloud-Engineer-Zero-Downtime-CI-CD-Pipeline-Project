variable "aws_region" {
  description = "AWS region for the NovaPay staging environment."
  type        = string
}

variable "name_prefix" {
  description = "Resource name prefix for the NovaPay staging environment."
  type        = string
  default     = "novapay-staging"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,40}$", var.name_prefix))
    error_message = "name_prefix must be 1-41 characters and contain only letters, numbers, hyphens, or underscores."
  }
}

variable "cluster_name" {
  description = "EKS cluster name for the NovaPay staging environment."
  type        = string
  default     = "novapay-staging-eks"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,99}$", var.cluster_name))
    error_message = "cluster_name must be 1-100 characters and contain only letters, numbers, hyphens, or underscores."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS control plane. The assessment requires Kubernetes 1.29+."
  type        = string
  default     = "1.33"

  validation {
    condition     = can(regex("^1\\.(2[9]|3[0-9])$", var.kubernetes_version))
    error_message = "kubernetes_version must be Kubernetes 1.29 or newer within the supported 1.x range."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the staging VPC."
  type        = string
  default     = "10.40.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR."
  }
}

variable "public_subnet_cidrs" {
  description = "Three public subnet CIDRs, one per Availability Zone."
  type        = list(string)
  default = [
    "10.40.0.0/24",
    "10.40.1.0/24",
    "10.40.2.0/24"
  ]

  validation {
    condition = length(var.public_subnet_cidrs) >= 3 && alltrue([
      for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "Provide at least three valid public subnet CIDRs."
  }
}

variable "private_subnet_cidrs" {
  description = "Three private subnet CIDRs, one per Availability Zone, used by EKS worker nodes."
  type        = list(string)
  default = [
    "10.40.10.0/24",
    "10.40.11.0/24",
    "10.40.12.0/24"
  ]

  validation {
    condition = length(var.private_subnet_cidrs) >= 3 && alltrue([
      for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "Provide at least three valid private subnet CIDRs."
  }
}

variable "node_group_name" {
  description = "Managed EKS node group name for staging."
  type        = string
  default     = "staging-system"
}

variable "node_instance_types" {
  description = "EC2 instance types for staging EKS nodes."
  type        = list(string)
  default     = ["t3.large"]

  validation {
    condition     = length(var.node_instance_types) > 0
    error_message = "Provide at least one node instance type."
  }
}

variable "node_min_size" {
  description = "Minimum number of staging worker nodes."
  type        = number
  default     = 3

  validation {
    condition     = var.node_min_size >= 1
    error_message = "node_min_size must be at least 1."
  }
}

variable "node_desired_size" {
  description = "Desired number of staging worker nodes."
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum number of staging worker nodes."
  type        = number
  default     = 5
}

variable "node_disk_size" {
  description = "Root EBS volume size in GiB for staging worker nodes."
  type        = number
  default     = 50

  validation {
    condition     = var.node_disk_size >= 20
    error_message = "node_disk_size must be at least 20 GiB."
  }
}

variable "application_log_retention_days" {
  description = "CloudWatch application-log retention for staging."
  type        = number
  default     = 60

  validation {
    condition     = var.application_log_retention_days >= 1
    error_message = "application_log_retention_days must be at least 1."
  }
}

variable "audit_log_retention_days" {
  description = "CloudWatch audit-log retention for staging."
  type        = number
  default     = 180

  validation {
    condition     = var.audit_log_retention_days >= 1
    error_message = "audit_log_retention_days must be at least 1."
  }
}

variable "alert_email" {
  description = "Optional SNS email endpoint for staging alerts. The recipient must confirm the subscription."
  type        = string
  default     = null

  validation {
    condition     = var.alert_email == null || can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alert_email))
    error_message = "alert_email must be null or a valid email address."
  }
}

variable "tags" {
  description = "Additional tags for the staging environment."
  type        = map(string)
  default     = {}
}
