# NovaPay Production Environment
# Never store credentials, tokens, passwords, private keys, or secrets here.
# Production consumes the SAME immutable and signed artifact promoted through
# Dev -> Staging -> Pre-Prod -> Production.

aws_region         = "ap-south-1"
name_prefix        = "novapay-production"
cluster_name       = "novapay-production-eks"
kubernetes_version = "1.33"

vpc_cidr = "10.60.0.0/16"

public_subnet_cidrs = [
  "10.60.0.0/24",
  "10.60.1.0/24",
  "10.60.2.0/24"
]

private_subnet_cidrs = [
  "10.60.10.0/24",
  "10.60.11.0/24",
  "10.60.12.0/24"
]

node_group_name     = "production-system"
node_instance_types = ["m6i.large", "m5.large"]
node_min_size       = 6
node_desired_size   = 6
node_max_size       = 12
node_disk_size      = 80

application_log_retention_days = 90
audit_log_retention_days       = 365

# alert_email = "sre@example.com"

tags = {
  Owner       = "DevOps"
  CostCenter  = "NOVAPAY-PRODUCTION"
  Criticality = "business-critical"
}
