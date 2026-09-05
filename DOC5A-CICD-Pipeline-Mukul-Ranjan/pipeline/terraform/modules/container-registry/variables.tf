variable "repository_key" {
  description = "JFrog Artifactory local Docker V2 repository key used for NovaPay container images."
  type        = string
  default     = "novapay-docker-local"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9._-]{0,127}$", var.repository_key))
    error_message = "repository_key must be 1-128 characters and contain only letters, numbers, dots, underscores, or hyphens."
  }
}

variable "tag_retention" {
  description = "Number of overwritten image tags retained by Artifactory by digest. Use this for traceability and controlled repository growth."
  type        = number
  default     = 10

  validation {
    condition     = var.tag_retention >= 1
    error_message = "tag_retention must be at least 1."
  }
}

variable "max_unique_tags" {
  description = "Maximum number of unique tags retained for a single Docker image. Set to 0 for no limit."
  type        = number
  default     = 50

  validation {
    condition     = var.max_unique_tags >= 0
    error_message = "max_unique_tags must be zero or greater."
  }
}
