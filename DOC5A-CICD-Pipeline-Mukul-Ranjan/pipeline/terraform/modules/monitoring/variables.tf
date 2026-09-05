variable "name_prefix" {
  description = "Prefix used for AWS monitoring resources."
  type        = string
  default     = "novapay"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,40}$", var.name_prefix))
    error_message = "name_prefix must be 1-41 characters and contain only letters, numbers, hyphens, or underscores."
  }
}

variable "environment" {
  description = "NovaPay deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "preprod", "production"], var.environment)
    error_message = "environment must be one of: dev, staging, preprod, production."
  }
}

variable "application_log_retention_days" {
  description = "CloudWatch retention period for application logs."
  type        = number
  default     = 90

  validation {
    condition     = var.application_log_retention_days >= 1
    error_message = "application_log_retention_days must be at least 1."
  }
}

variable "audit_log_retention_days" {
  description = "CloudWatch retention period for audit logs."
  type        = number
  default     = 365

  validation {
    condition     = var.audit_log_retention_days >= 1
    error_message = "audit_log_retention_days must be at least 1."
  }
}

variable "alert_email" {
  description = "Optional email endpoint for the SNS alert topic. The recipient must confirm the SNS subscription."
  type        = string
  default     = null

  validation {
    condition     = var.alert_email == null || can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alert_email))
    error_message = "alert_email must be null or a valid email address."
  }
}

variable "tags" {
  description = "Additional tags applied to supported AWS monitoring resources."
  type        = map(string)
  default     = {}
}
