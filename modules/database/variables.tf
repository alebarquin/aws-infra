/*==== Input variable definitions ======*/

variable "region" {
  description = "AWS region to create the resources"
  type        = string
}

variable "environment" {
  description = "Name for the environment to provision"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID created with Networking module"
  type        = string
}

variable "database_subnets_id" {
  description = "Database subnets IDs created with Networking module"
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "Private subnets CIDRs created with Networking module"
  type        = list(string)
}

variable "client_vpn_sg_id" {
  description = "Client VPN security group ID created with Client-VPN module"
  type        = list(string)
}

variable "s3_backups" {
  description = "Name for the s3 bucket to host RDS backups"
  type        = string
}

variable "dns_zone_id" {
  description = "AWS Route 53 Hosted Zone ID"
  type        = string
}

variable "dns_rds" {
  description = "DNS name to access RDS endpoint. E.G: rds-staging.tl.techmatters.org"
  type        = string
}

variable "rds_allocated_storage" {
  description = "RDS volume size"
  type        = string
}

variable "rds_max_allocated_storage" {
  description = "RDS volume size limit for autoscaling"
  type        = string
}

variable "rds_storage_type" {
  description = "RDS volume storage type"
  type        = string
}

variable "rds_database_port" {
  description = "RDS port for incoming connections"
  type        = string
}

variable "rds_database_name" {
  description = "RDS database name for HRM"
  type        = string
}

variable "rds_engine" {
  description = "RDS engine for RDS instance"
  type        = string
}

variable "rds_engine_version" {
  description = "RDS engine version"
  type        = string
}

variable "rds_instance_class" {
  description = "RDS instance type to run"
  type        = string
}

variable "rds_multi_az" {
  description = "Defines if the RDS instance will have a database copy in another availability zone"
  type        = string
}

variable "rds_user" {
  description = "Root admin user for RDS instance"
  type        = string
}

variable "rds_master_password" {
  description = "Root admin password for RDS instance"
  type        = string
}

variable "rds_ca" {
  description = "AWS Certification authority for RDS certificates"
  type        = string
}

/*==== 
variable "rds_snapshot_id" {
  description = "Enable this variable to create the RDS database instance from a specific snapshot (must be encrypted!)"
  type        = string
}
======*/

variable "rds_apply_immediately" {
  description = "Defines whether any database modifications are applied immediately, or during the next maintenance window."
  type        = bool
}

variable "deletion_protection" {
  description = "Defines if the RDS instance will be protected to accidental deletion"
  type        = bool
}

variable "publicly_accessible" {
  description = "Defines if the RDS instance will be publicly accessible"
  type        = bool
}

variable "rds_bkp_retention" {
  description = "The days to retain database backups"
  type        = number
}

variable "rds_bkp_window" {
  description = "The daily time range (in UTC) during which automated backups are created"
  type        = string
}

variable "rds_main_window" {
  description = "The time range (in UTC) to perform maintenance in the RDS database"
  type        = string
}

variable "rds_final_snapshot" {
  description = "Defines if the RDS instance will skip a final snapshot after deletion (true skips and false does it)"
  type        = bool
}

variable "rds_final_snapshot_id" {
  description = "The name of your final DB snapshot when this DB instance is deleted. Must be provided if skip_final_snapshot is set to false"
  type        = string
}

variable "cw_logs_export" {
  description = "List of Postgresql values to add to CloudWatch"
  type        = list(string)
}