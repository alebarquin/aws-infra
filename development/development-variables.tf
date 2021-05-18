/*==== Input variable definitions ======*/

/*==== General variables ======*/
variable "region" {
  description = "AWS Deployment region"
  default = "us-east-1"
}

variable "environment" {
  description = "Name of the environment to provision"
  type        = string
  default     = "Development"
}

variable "availability_zones" {
  description = "AWS availability zones to host resources"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  }

variable "dns_zone_id" {
  description = "AWS Route 53 Hosted Zone ID"
  type        = string
  default     = "ZO912ELMYXCVS"
}  

/*==== Networking module variables ======*/
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnets_cidr" {
  description = "Public subnets CIDRs for VPC"
  type        = list(string)
  default     = ["10.10.10.0/24", "10.10.11.0/24"]
}

variable "private_subnets_cidr" {
  description = "Private subnets CIDRs for VPC"
  type        = list(string)
  default     = ["10.10.20.0/24", "10.10.21.0/24"]
}

variable "database_subnets_cidr" {
  description = "Database subnets CIDRs for VPC"
  type        = list(string)
  default     = ["10.10.30.0/24", "10.10.31.0/24"]
}
