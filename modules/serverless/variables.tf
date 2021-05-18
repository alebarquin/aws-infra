/*==== Input variable definitions ======*/

variable "region" {
  description = "AWS region to create the resources"
  type        = string
}

variable "environment" {
  description = "Name for the environment to provision"
  type        = string
}

variable "application" {
  description = "Name for the application to run in ECS cluster"
  type        = string
}

variable "alb_tls_cert_arn" {
  description = "ARN for TLS SSL certificate"
  type        = string
}

variable "s3_variables" {
  description = "Name for the s3 bucket to host environment variables"
  type        = string
}

variable "container_port" {
  description = "Container port used by the application"
  type        = string
}

variable "container_image" {
  description = "Docker image name tag in ECR"
  type        = string
}

variable "client_vpn_sg_id" {
  description = "Client VPN security group ID created with Client-VPN module"
  type        = list(string)
}

variable "dns_zone_id" {
  description = "AWS Route 53 Hosted Zone ID"
  type        = string
}

variable "dns_public" {
  description = "Public name to access HRM application. E.G: hrm-staging.tl.techmatters.org"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID created with Networking module"
  type        = string
}

variable "api_log_retention" {
  description = "Days for HRM API log retention"
  type        = string
}

variable "public_subnets_id" {
  description = "Public subnets IDs created with Networking module"
  type        = list(string)
}

variable "private_subnets_id" {
  description = "Private subnets IDs created with Networking module"
  type        = list(string)
}

variable "public_subnets_cidr" {
  description = "Public subnets CIDRs created with Networking module"
  type        = list(string)
}