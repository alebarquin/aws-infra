/*==== Monitoring module ======*/
terraform {
  required_version = ">= 0.12"
}

/*==== Cloud provider ======*/
provider "aws" {
  region  = var.region
}

/*==== SNS topic and subscriptions ======*/
resource "aws_sns_topic" "aws_alarms" {
  name          = "AWS-${var.environment}-alarms"
  display_name  = "AWS-${var.environment}-alarms"
  provisioner "local-exec" {
    command = "sh sns_subscription.sh"
    environment = {
      sns_arn = self.arn
      sns_emails = var.sns_subscription_email_address_list
    }
  }
  tags = {
    Name        = "${var.environment}-sns-topic"
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "sms_subscription" {
  count     = length(var.sns_subscription_phone_number_list)
  topic_arn = aws_sns_topic.aws_alarms.arn
  protocol  = "sms"
  endpoint  = element(var.sns_subscription_phone_number_list, count.index)
}

/*==== RDS database event subscription ======*/
resource "aws_db_event_subscription" "hrmdb_subs" {
  name      = "${var.environment}-hrmdb-event-subscription"
  sns_topic = aws_sns_topic.aws_alarms.arn

  source_type = "db-instance"
  source_ids  = [var.db_instance_id]

  event_categories = [
    "availability",
    "deletion",
    "failover",
    "failure",
    "low storage",
    "notification",
    "recovery",
    "restoration",
  ]

  tags = {
    Name        = "${var.environment}-hrmdb-event-subscription"
    Environment = var.environment
  }
}

/*==== AWS Route53 healthchecks ======*/
/*==== HRM public URL check ======*/
resource "aws_route53_health_check" "r53_hrm" {
  fqdn              = var.hrm_public_dns
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "6"
  request_interval  = "30"
  measure_latency   = "1"
  tags = {
    Name        = "${var.environment}-hrm-healthcheck"
    Environment = var.environment
   }
}

/*==== Web chat public URL check ======*/
resource "aws_route53_health_check" "r53_chat" {
  fqdn              = var.chat_public_dns
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "6"
  request_interval  = "30"
  measure_latency   = "1"
  tags = {
    Name        = "${var.environment}-webchat-healthcheck"
    Environment = var.environment
   }
}

/*==== Twilio Flex public URL check ======*/
resource "aws_route53_health_check" "r53_flex" {
  fqdn              = var.flex_public_dns
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "6"
  request_interval  = "30"
  measure_latency   = "1"
  tags = {
    Name        = "${var.environment}-flex-healthcheck"
    Environment = var.environment
   }
}