output "application_log_group_name" {
  description = "CloudWatch log group for NovaPay application logs."
  value       = aws_cloudwatch_log_group.application.name
}

output "application_log_group_arn" {
  description = "ARN of the NovaPay application CloudWatch log group."
  value       = aws_cloudwatch_log_group.application.arn
}

output "audit_log_group_name" {
  description = "CloudWatch log group for NovaPay audit logs."
  value       = aws_cloudwatch_log_group.audit.name
}

output "audit_log_group_arn" {
  description = "ARN of the NovaPay audit CloudWatch log group."
  value       = aws_cloudwatch_log_group.audit.arn
}

output "alerts_topic_arn" {
  description = "SNS topic ARN used as an AWS-side alert notification integration point."
  value       = aws_sns_topic.alerts.arn
}

output "alerts_topic_name" {
  description = "SNS topic name used for NovaPay monitoring alerts."
  value       = aws_sns_topic.alerts.name
}
