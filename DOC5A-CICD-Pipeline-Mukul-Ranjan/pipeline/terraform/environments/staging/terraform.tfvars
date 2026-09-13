# NovaPay Staging Environment
# No credentials or secrets belong in this file.
# Staging must promote and deploy the same immutable artifact that passed Dev.

aws_region = "ap-south-1"

name_prefix        = "novapay-staging"
cluster_name       = "novapay-staging-eks"
kubernetes_version = "1.33"

vpc_cidr = "10.40.0.0/16"

public_subnet_cidrs = [
  "10.40.0.0/24",
  "10.40.1.0/24",
  "10.40.2.0/24"
]

private_subnet_cidrs = [
  "10.40.10.0/24",
  "10.40.11.0/24",
  "10.40.12.0/24"
]

node_group_name     = "staging-system"
node_instance_types = ["t3.large"]
node_min_size       = 3
node_desired_size   = 3
node_max_size       = 5
node_disk_size      = 50

application_log_retention_days = 60
audit_log_retention_days       = 180

# Set this only when an SNS email subscription is required:
# alert_email = "devops@example.com"

tags = {
  Owner      = "DevOps"
  CostCenter = "NOVAPAY-STAGING"
}
