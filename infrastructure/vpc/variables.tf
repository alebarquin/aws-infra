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

variable "availability_zone" {
  description = "AWS availability zone to host resources"
  type        = string
  }

variable "public_subnet_cidr" {
  description = "Public subnet CIDR for VPC"
  type        = string
}