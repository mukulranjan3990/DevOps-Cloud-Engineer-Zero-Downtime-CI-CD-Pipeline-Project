output "environment" {
  description = "Deployment environment."
  value       = "dev"
}

output "vpc_id" {
  description = "VPC ID for the NovaPay development environment."
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by the EKS cluster."
  value       = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs for internet-facing infrastructure such as load balancers."
  value       = module.networking.public_subnet_ids
}

output "eks_cluster_name" {
  description = "Development EKS cluster name."
  value       = module.kubernetes_cluster.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Development EKS Kubernetes API endpoint."
  value       = module.kubernetes_cluster.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes version of the development EKS control plane."
  value       = module.kubernetes_cluster.cluster_version
}

output "eks_node_group_name" {
  description = "Development EKS managed node group name."
  value       = module.kubernetes_cluster.node_group_name
}

output "application_log_group_name" {
  description = "CloudWatch application log group."
  value       = module.monitoring.application_log_group_name
}

output "audit_log_group_name" {
  description = "CloudWatch audit log group."
  value       = module.monitoring.audit_log_group_name
}

output "alerts_topic_arn" {
  description = "SNS topic used for development monitoring alerts."
  value       = module.monitoring.alerts_topic_arn
}
