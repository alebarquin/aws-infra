/*==== Input variable definitions ======*/

variable "region" {
  description = "AWS Deployment region"
  type        = string
}

variable "environment" {
  description = "Name of the environment to provision"
  type        = string
}

variable "sns_subscription_email_address_list" {
  type = string
  description = "List of email addresses as string(space separated)"
}

variable "sns_subscription_phone_number_list" {
  type = list(string)
  description = "List of phone numbers for SMS alerts"
}

variable "db_instance_id" {
  description = "The instance ID of the RDS database instance that you want to monitor"
  type        = string
}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster that you want to monitor"
  type        = string
}

variable "ecs_service_name" {
  description = "The name of the ECS service that you want to monitor"
  type        = string
}

variable "hrm_public_dns" {
  description = "Public name to access HRM application. E.G: hrm-staging.tl.techmatters.org"
  type        = string
}

variable "chat_public_dns" {
  description = "Public name to access Web Chat. E.G: chat-staging.tl.techmatters.org"
  type        = string
}

variable "flex_public_dns" {
  description = "Public name to access Twilio Flex. E.G: flex.twilio.com"
  type        = string
}