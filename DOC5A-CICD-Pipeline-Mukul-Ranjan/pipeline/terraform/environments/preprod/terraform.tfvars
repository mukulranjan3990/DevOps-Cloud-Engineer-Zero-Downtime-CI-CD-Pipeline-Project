# NovaPay Pre-Production Environment
# No credentials or application secrets belong in this file.
# Pre-production consumes the SAME immutable artifact promoted from Staging.

aws_region = "ap-south-1"

name_prefix        = "novapay-preprod"
cluster_name       = "novapay-preprod-eks"
kubernetes_version = "1.33"

vpc_cidr = "10.50.0.0/16"

public_subnet_cidrs = [
  "10.50.0.0/24",
  "10.50.1.0/24",
  "10.50.2.0/24"
]

private_subnet_cidrs = [
  "10.50.10.0/24",
  "10.50.11.0/24",
  "10.50.12.0/24"
]

node_group_name     = "preprod-system"
node_instance_types = ["t3.large"]
node_min_size       = 4
node_desired_size   = 4
node_max_size       = 6
node_disk_size      = 50

application_log_retention_days = 90
audit_log_retention_days       = 365

# Set this only when an SNS email subscription is required:
# alert_email = "devops@example.com"

tags = {
  Owner      = "DevOps"
  CostCenter = "NOVAPAY-PREPROD"
}
