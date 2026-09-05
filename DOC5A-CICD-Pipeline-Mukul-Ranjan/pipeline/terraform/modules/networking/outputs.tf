output "vpc_id" {
  description = "ID of the NovaPay VPC."
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN of the NovaPay VPC."
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "CIDR block assigned to the NovaPay VPC."
  value       = aws_vpc.this.cidr_block
}

output "availability_zones" {
  description = "Availability Zones used by the networking module."
  value       = local.availability_zones
}

output "public_subnet_ids" {
  description = "IDs of public subnets used for internet-facing load balancers and NAT gateways."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets intended for the EKS control plane ENIs and worker nodes."
  value       = aws_subnet.private[*].id
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of private route tables, one per Availability Zone."
  value       = aws_route_table.private[*].id
}

output "internet_gateway_id" {
  description = "ID of the VPC internet gateway."
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_ids" {
  description = "IDs of NAT gateways. Empty when NAT gateways are disabled."
  value       = aws_nat_gateway.this[*].id
}

output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log when enabled."
  value       = var.enable_vpc_flow_logs ? aws_flow_log.this[0].id : null
}

output "vpc_flow_log_group_name" {
  description = "CloudWatch Log Group receiving VPC Flow Logs when enabled."
  value       = var.enable_vpc_flow_logs ? aws_cloudwatch_log_group.vpc_flow_logs[0].name : null
}
