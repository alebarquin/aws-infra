/*==== Input variable definitions ======*/

/*==== General variables ======*/
variable "region" {
  description = "AWS Deployment region"
  default = "us-east-1"
}

variable "environment" {
  description = "Name of the environment to provision"
  type        = string
  default     = "infrastructure"
}

variable "availability_zone" {
  description = "AWS availability zone to host resources"
  type        = string
  default     = "us-east-1a"
  }

/*==== VPC module variables ======*/
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/20"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR for VPC"
  type        = string
  default     = "10.0.0.0/24"
}

/*==== CertServer module variables ======*/
variable "ami" {
  description = "Ubuntu 20.04 LTS AMI ID. Get this value from AWS public AMIs: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;search=Ubuntu%2020.04%20LTS;sort=name"
  type        = string
  default     = "ami-089e6b3b328e5a2c1"
}

variable "ec2_instance_type" {
  description = "EC2 instance type for the server. Default: t3.micro"
  type        = string
  default     = "t3.micro"
}