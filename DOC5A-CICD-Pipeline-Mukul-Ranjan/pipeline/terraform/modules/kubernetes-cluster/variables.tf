variable "cluster_name" {
  description = "Name of the Amazon EKS cluster."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,99}$", var.cluster_name))
    error_message = "cluster_name must be 1-100 characters and contain only letters, numbers, hyphens, or underscores."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes minor version for the EKS control plane. The assessment requires Kubernetes 1.29+."
  type        = string
  default     = "1.33"

  validation {
    condition     = can(regex("^1\\.(2[9]|3[0-9])$", var.kubernetes_version))
    error_message = "kubernetes_version must be Kubernetes 1.29 or newer within the supported 1.x range."
  }
}

variable "vpc_id" {
  description = "VPC ID in which the EKS cluster will run."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the EKS control-plane ENIs and managed worker nodes. Use subnets in at least three Availability Zones for production."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 3
    error_message = "Provide at least three private subnet IDs across Availability Zones for high availability."
  }
}

variable "cluster_endpoint_private_access" {
  description = "Whether the EKS Kubernetes API endpoint is reachable privately from the VPC."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS Kubernetes API endpoint is reachable from the public internet. Keep false for a private production control plane."
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the EKS public API endpoint when public access is enabled."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.cluster_endpoint_public_access_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "Every cluster_endpoint_public_access_cidrs value must be a valid CIDR."
  }
}

variable "cluster_log_types" {
  description = "EKS control-plane log types sent to CloudWatch Logs."
  type        = list(string)
  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]
}

variable "enable_encryption" {
  description = "Enable envelope encryption for Kubernetes secrets using a customer-managed KMS key."
  type        = bool
  default     = true
}

variable "node_group_name" {
  description = "Name of the managed EKS worker node group."
  type        = string
  default     = "system"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,62}$", var.node_group_name))
    error_message = "node_group_name must be 1-63 characters and contain only letters, numbers, hyphens, or underscores."
  }
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed worker node group."
  type        = list(string)
  default     = ["t3.large"]

  validation {
    condition     = length(var.node_instance_types) > 0
    error_message = "Provide at least one node instance type."
  }
}

variable "node_capacity_type" {
  description = "Capacity type for worker nodes. ON_DEMAND is preferred for predictable banking workloads."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 3

  validation {
    condition     = var.node_min_size >= 1
    error_message = "node_min_size must be at least 1."
  }
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 6
}

variable "node_disk_size" {
  description = "Root EBS volume size in GiB for each managed worker node."
  type        = number
  default     = 50

  validation {
    condition     = var.node_disk_size >= 20
    error_message = "node_disk_size must be at least 20 GiB."
  }
}

variable "node_labels" {
  description = "Kubernetes labels applied to all nodes in the managed node group."
  type        = map(string)
  default = {
    workload = "platform"
  }
}

variable "node_taints" {
  description = "Kubernetes taints applied to all nodes in the managed node group."
  type = list(object({
    key    = string
    value  = optional(string)
    effect = string
  }))
  default = []
}

variable "node_update_max_unavailable" {
  description = "Maximum number of worker nodes that can be unavailable during a managed node-group update."
  type        = number
  default     = 1

  validation {
    condition     = var.node_update_max_unavailable >= 1
    error_message = "node_update_max_unavailable must be at least 1."
  }
}

variable "tags" {
  description = "Additional tags applied to supported AWS resources."
  type        = map(string)
  default     = {}
}

variable "access_entries" {
  description = "Optional EKS access entries. Keys are IAM principal ARNs; values define Kubernetes access policies."
  type = map(object({
    kubernetes_groups = optional(list(string), [])
    policy_associations = optional(map(object({
      policy_arn = string
      access_scope = object({
        type       = string
        namespaces = optional(list(string), [])
      })
    })), {})
  }))
  default = {}
}
