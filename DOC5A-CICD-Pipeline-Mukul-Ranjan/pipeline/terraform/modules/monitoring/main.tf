terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.100, < 6.0"
    }
  }
}

locals {
  common_tags = merge(
    {
      Project   = "NovaPay"
      ManagedBy = "Terraform"
      Component = "monitoring"
    },
    var.tags
  )
}

resource "aws_cloudwatch_log_group" "application" {
  name              = "/novapay/${var.environment}/application"
  retention_in_days = var.application_log_retention_days

  tags = merge(
    local.common_tags,
    {
      Environment = var.environment
      LogType     = "application"
    }
  )
}

resource "aws_cloudwatch_log_group" "audit" {
  name              = "/novapay/${var.environment}/audit"
  retention_in_days = var.audit_log_retention_days

  tags = merge(
    local.common_tags,
    {
      Environment = var.environment
      LogType     = "audit"
    }
  )
}

resource "aws_sns_topic" "alerts" {
  name = "${var.name_prefix}-${var.environment}-alerts"

  tags = merge(
    local.common_tags,
    {
      Environment = var.environment
    }
  )
}

resource "aws_sns_topic_subscription" "email" {
  count = var.alert_email == null ? 0 : 1

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Prometheus, Grafana, OpenTelemetry Collector, Loki, Alertmanager,
# and SLO tooling are deployed in Kubernetes through Helm/GitOps.
# This module provides durable AWS-side log and alerting integration points.
