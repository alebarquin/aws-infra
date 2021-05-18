/*==== Input variable definitions ======*/

variable "region" {
  description = "AWS Deployment region"
  type        = string
}

variable "environment" {
  description = "Name of the environment to provision"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "AWS availability zones to host resources"
  type        = list(string)
  }

variable "public_subnets_cidr" {
  description = "Public subnets CIDRs for VPC"
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "Private subnets CIDRs for VPC"
  type        = list(string)
}

variable "database_subnets_cidr" {
  description = "Database subnets CIDRs for VPC"
  type        = list(string)
}