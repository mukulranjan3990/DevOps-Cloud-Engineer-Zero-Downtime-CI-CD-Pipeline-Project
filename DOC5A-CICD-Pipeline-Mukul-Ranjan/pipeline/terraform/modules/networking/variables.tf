variable "name" {
  description = "Base name used for NovaPay networking resources."
  type        = string
  default     = "novapay"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,62}$", var.name))
    error_message = "name must be 1-63 characters and contain only letters, numbers, and hyphens."
  }
}

variable "cluster_name" {
  description = "EKS cluster name used for Kubernetes subnet discovery tags."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the NovaPay VPC."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "az_count" {
  description = "Number of Availability Zones to use. Production should use at least three for high availability."
  type        = number
  default     = 3

  validation {
    condition     = var.az_count >= 3 && var.az_count <= 6
    error_message = "az_count must be between 3 and 6."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets. Provide at least az_count entries."
  type        = list(string)
  default = [
    "10.20.0.0/24",
    "10.20.1.0/24",
    "10.20.2.0/24",
  ]

  validation {
    condition = alltrue([
      for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "Every public_subnet_cidrs entry must be a valid IPv4 CIDR block."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private EKS workload subnets. Provide at least az_count entries."
  type        = list(string)
  default = [
    "10.20.10.0/24",
    "10.20.11.0/24",
    "10.20.12.0/24",
  ]

  validation {
    condition = alltrue([
      for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "Every private_subnet_cidrs entry must be a valid IPv4 CIDR block."
  }
}

variable "enable_nat_gateway" {
  description = "Create NAT gateways so private EKS nodes can reach external services without public IP addresses."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for all private subnets. Keep false in production to avoid a single-AZ egress dependency."
  type        = bool
  default     = false
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch for security monitoring and audit evidence."
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  description = "CloudWatch retention period for VPC Flow Logs."
  type        = number
  default     = 90

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
    ], var.flow_log_retention_days)
    error_message = "flow_log_retention_days must be a valid CloudWatch Logs retention value."
  }
}

variable "enable_dns_support" {
  description = "Enable DNS resolution in the VPC. Required for normal EKS/service discovery operation."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to supported networking resources."
  type        = map(string)
  default     = {}
}
