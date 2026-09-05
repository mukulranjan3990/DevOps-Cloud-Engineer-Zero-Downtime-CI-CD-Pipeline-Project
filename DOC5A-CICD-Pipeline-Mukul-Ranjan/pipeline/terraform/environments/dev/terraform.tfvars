# NovaPay Development Environment
# No secrets belong in this file.
# JFrog credentials are supplied through JFROG_URL/JFROG_ACCESS_TOKEN
# or the CI/CD secret-management mechanism.

aws_region = "ap-south-1"

name_prefix   = "novapay-dev"
cluster_name  = "novapay-dev-eks"
kubernetes_version = "1.33"

vpc_cidr = "10.30.0.0/16"

public_subnet_cidrs = [
  "10.30.0.0/24",
  "10.30.1.0/24",
  "10.30.2.0/24"
]

private_subnet_cidrs = [
  "10.30.10.0/24",
  "10.30.11.0/24",
  "10.30.12.0/24"
]

node_group_name     = "dev-system"
node_instance_types = ["t3.large"]
node_min_size       = 3
node_desired_size   = 3
node_max_size       = 4
node_disk_size      = 40

application_log_retention_days = 30
audit_log_retention_days       = 90

# Set this only when you want an SNS email subscription:
# alert_email = "devops@example.com"

tags = {
  Owner      = "DevOps"
  CostCenter = "NOVAPAY-DEV"
}
