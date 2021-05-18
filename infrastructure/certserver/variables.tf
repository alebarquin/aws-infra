/*==== Input variable definitions ======*/

variable "region" {
  description = "AWS Deployment region"
  type        = string
}

variable "environment" {
  description = "Name of the environment to provision"
  type        = string
}

variable "availability_zone" {
  description = "AWS availability zone to host resources"
  type        = string
  }

variable "vpc_id" {
  description = "VPC ID created with VPC module"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID created with VPC module"
  type        = string
}

variable "ami" {
  description = "Ubuntu 20.04 LTS AMI ID. Get this value from AWS public AMIs: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;search=Ubuntu%2020.04%20LTS;sort=name"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type for the server. Default: t3.micro"
  type        = string
}