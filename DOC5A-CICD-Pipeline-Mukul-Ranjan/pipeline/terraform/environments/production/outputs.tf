output "environment" {
  description = "Deployment environment."
  value       = "production"
}

output "vpc_id" {
  description = "Production VPC ID."
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "Private EKS subnet IDs."
  value       = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.networking.public_subnet_ids
}

output "eks_cluster_name" {
  description = "Production EKS cluster name."
  value       = module.kubernetes_cluster.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Production EKS API endpoint."
  value       = module.kubernetes_cluster.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Production Kubernetes version."
  value       = module.kubernetes_cluster.cluster_version
}

output "eks_node_group_name" {
  description = "Production managed EKS node group name."
  value       = module.kubernetes_cluster.node_group_name
}

output "application_log_group_name" {
  description = "Production application log group."
  value       = module.monitoring.application_log_group_name
}

output "audit_log_group_name" {
  description = "Production audit log group."
  value       = module.monitoring.audit_log_group_name
}

output "alerts_topic_arn" {
  description = "Production monitoring SNS topic ARN."
  value       = module.monitoring.alerts_topic_arn
}