variable "aws_region" {
  description = "AWS region for NovaPay production."
  type        = string
}

variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
  default     = "novapay-production"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,40}$", var.name_prefix))
    error_message = "name_prefix must be 1-41 characters and use letters, numbers, hyphens, or underscores."
  }
}

variable "cluster_name" {
  description = "Production EKS cluster name."
  type        = string
  default     = "novapay-production-eks"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,99}$", var.cluster_name))
    error_message = "cluster_name must be 1-100 characters and use letters, numbers, hyphens, or underscores."
  }
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version; assessment requires 1.29+."
  type        = string
  default     = "1.33"

  validation {
    condition     = can(regex("^1\\.(2[9]|3[0-9])$", var.kubernetes_version))
    error_message = "kubernetes_version must be Kubernetes 1.29 or newer within the supported 1.x range."
  }
}

variable "vpc_cidr" {
  description = "Production VPC CIDR."
  type        = string
  default     = "10.60.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR."
  }
}

variable "public_subnet_cidrs" {
  description = "Three public subnet CIDRs across Availability Zones."
  type        = list(string)
  default = [
    "10.60.0.0/24",
    "10.60.1.0/24",
    "10.60.2.0/24"
  ]

  validation {
    condition = length(var.public_subnet_cidrs) >= 3 && alltrue([
      for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))
    ])

    error_message = "Provide at least three valid public subnet CIDRs."
  }
}

variable "private_subnet_cidrs" {
  description = "Three private subnet CIDRs across Availability Zones for EKS nodes."
  type        = list(string)
  default = [
    "10.60.10.0/24",
    "10.60.11.0/24",
    "10.60.12.0/24"
  ]

  validation {
    condition = length(var.private_subnet_cidrs) >= 3 && alltrue([
      for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))
    ])

    error_message = "Provide at least three valid private subnet CIDRs."
  }
}

variable "node_group_name" {
  description = "Production managed EKS node group name."
  type        = string
  default     = "production-system"
}

variable "node_instance_types" {
  description = "EC2 instance types for production EKS nodes."
  type        = list(string)
  default     = ["m6i.large", "m5.large"]

  validation {
    condition     = length(var.node_instance_types) > 0
    error_message = "Provide at least one node instance type."
  }
}

variable "node_min_size" {
  description = "Minimum production worker nodes."
  type        = number
  default     = 6

  validation {
    condition     = var.node_min_size >= 1
    error_message = "node_min_size must be at least 1."
  }
}

variable "node_desired_size" {
  description = "Desired production worker nodes."
  type        = number
  default     = 6
}

variable "node_max_size" {
  description = "Maximum production worker nodes."
  type        = number
  default     = 12
}

variable "node_disk_size" {
  description = "Root EBS size in GiB."
  type        = number
  default     = 80

  validation {
    condition     = var.node_disk_size >= 20
    error_message = "node_disk_size must be at least 20 GiB."
  }
}

variable "application_log_retention_days" {
  description = "CloudWatch application log retention."
  type        = number
  default     = 90

  validation {
    condition     = var.application_log_retention_days >= 1
    error_message = "Retention must be at least 1 day."
  }
}

variable "audit_log_retention_days" {
  description = "CloudWatch audit log retention."
  type        = number
  default     = 365

  validation {
    condition     = var.audit_log_retention_days >= 1
    error_message = "Retention must be at least 1 day."
  }
}

variable "alert_email" {
  description = "Optional SNS email endpoint for production alerts."
  type        = string
  default     = null

  validation {
    condition     = var.alert_email == null || can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alert_email))
    error_message = "alert_email must be null or a valid email address."
  }
}

variable "tags" {
  description = "Additional production tags."
  type        = map(string)
  default     = {}
}
