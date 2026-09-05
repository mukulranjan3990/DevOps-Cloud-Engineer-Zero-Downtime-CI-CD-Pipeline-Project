output "environment" {
  description = "Deployment environment."
  value       = "preprod"
}

output "vpc_id" {
  description = "VPC ID for the NovaPay pre-production environment."
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by the pre-production EKS cluster."
  value       = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs for internet-facing infrastructure."
  value       = module.networking.public_subnet_ids
}

output "eks_cluster_name" {
  description = "Pre-production EKS cluster name."
  value       = module.kubernetes_cluster.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Pre-production EKS Kubernetes API endpoint."
  value       = module.kubernetes_cluster.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes version of the pre-production EKS control plane."
  value       = module.kubernetes_cluster.cluster_version
}

output "eks_node_group_name" {
  description = "Pre-production EKS managed node group name."
  value       = module.kubernetes_cluster.node_group_name
}

output "application_log_group_name" {
  description = "CloudWatch application log group for pre-production."
  value       = module.monitoring.application_log_group_name
}

output "audit_log_group_name" {
  description = "CloudWatch audit log group for pre-production."
  value       = module.monitoring.audit_log_group_name
}

output "alerts_topic_arn" {
  description = "SNS topic used for pre-production monitoring alerts."
  value       = module.monitoring.alerts_topic_arn
}
