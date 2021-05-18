/*==== Input variable definitions ======*/

/*==== General variables ======*/
variable "region" {
  description = "AWS Deployment region"
  default = "us-east-1"
}

variable "environment" {
  description = "Name of the environment to provision"
  type        = string
  default     = "staging"
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
  default     = "10.20.0.0/20"
}

variable "public_subnets_cidr" {
  description = "Public subnets CIDRs for VPC"
  type        = list(string)
  default     = ["10.20.0.0/24", "10.20.1.0/24"]
}

variable "private_subnets_cidr" {
  description = "Private subnets CIDRs for VPC"
  type        = list(string)
  default     = ["10.20.5.0/24", "10.20.6.0/24"]
}

variable "database_subnets_cidr" {
  description = "Database subnets CIDRs for VPC"
  type        = list(string)
  default     = ["10.20.10.0/24", "10.20.11.0/24"]
}

/*==== Client-VPN module variables ======*/
variable "server_cert" {
  description = "VPN Server certificate ARN. Get this value from AWS Certificate Manager console"
  type        = string
  default     = "arn:aws:acm:us-east-1:712893914485:certificate/49a25cb7-409c-4f26-930d-62761fbf983e"
}

variable "client_cert" {
  description = "VPN Client certificate ARN. Get this value from AWS Certificate Manager console"
  type        = string
  default     = "arn:aws:acm:us-east-1:712893914485:certificate/bc36f559-6d81-42ae-b81b-a8208e262bb9"
}

variable "vpn_log_retention" {
  description = "Days for VPN log retention"
  type        = string
  default     = "365"
}

variable "client_cidr_block" {
  description = "The CIDR block to assign to VPN clients. Must be different from VPC CIDR or any route in VPC route table and the range must have a block size that is between /12 and /22"
  type        = string
  default     = "10.200.0.0/22"
}

variable "split_tunnel" {
  description = "Pushes the route table of the VPN endpoint to the client so that only part of the traffic goes through the VPN endpoint. Values: true or false"
  type        = bool
  default     = true
}

variable "dns_servers" {
  description = "List of DNS servers to be used by the VPN endpoint"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

/*==== Serverless module variables ======*/
variable "application" {
  description = "Name for the application to run in ECS cluster"
  type        = string
  default     = "hrm"
}

variable "alb_tls_cert_arn" {
  description = "ARN for TLS SSL certificate"
  type        = string
  default     = "arn:aws:acm:us-east-1:712893914485:certificate/68c84a89-05f5-4452-b54b-0d568da0c934"
}

variable "s3_variables" {
  description = "Name for the s3 bucket to host environment variables"
  type        = string
  default     = "tl-hrm-vars-staging"
}

variable "container_port" {
  description = "Container port used by the application"
  type        = string
  default     = "8080"
}

variable "container_image" {
  description = "Docker image name tag in ECR"
  type        = string
  default     = "hrm"
}

variable "dns_public" {
  description = "Public name to access HRM application. E.G: hrm-staging.tl.techmatters.org"
  type        = string
  default     = "hrm-test.tl.techmatters.org"
}

variable "api_log_retention" {
  description = "Days for HRM API log retention"
  type        = string
  default     = "7"
}

/*==== Database module variables ======*/
variable "s3_backups" {
  description = "Name for the s3 bucket to host RDS backups"
  type        = string
  default     = "tl-rds-backups-staging"
}

variable "dns_rds" {
  description = "DNS name to access RDS endpoint. E.G: rds-staging.tl.techmatters.org"
  type        = string
  default     = "rds-staging.tl.techmatters.org"
}

variable "rds_allocated_storage" {
  description = "RDS volume size"
  type        = string
  default     = "20"
}

variable "rds_max_allocated_storage" {
  description = "RDS volume size limit for autoscaling"
  type        = string
  default     = "40"
}

variable "rds_storage_type" {
  description = "RDS volume storage type"
  type        = string
  default     = "gp2"
}

variable "rds_database_port" {
  description = "RDS port for incoming connections"
  type        = string
  default     = "5432"
}

variable "rds_database_name" {
  description = "RDS database name for HRM"
  type        = string
  default     = "hrmdb"
}

variable "rds_engine" {
  description = "RDS engine for RDS instance"
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "12"
}

variable "rds_instance_class" {
  description = "RDS instance type to run"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_multi_az" {
  description = "Defines if the RDS instance will have a database copy in another availability zone"
  type        = string
  default     = "false"
}

variable "rds_user" {
  description = "Root admin user for RDS instance"
  type        = string
  default     = "hrm"
}

variable "rds_master_password" {
  description = "Root admin password for RDS instance"
  type        = string
}

variable "rds_ca" {
  description = "AWS Certification authority for RDS certificates"
  type        = string
  default     = "rds-ca-2019"
}

/*==== 
variable "rds_snapshot_id" {
  description = "Enable this variable to create the RDS database instance from a specific snapshot (must be encrypted!)"
  type        = string
  default     = "Snapshot_name"
}
======*/

variable "rds_apply_immediately" {
  description = "Defines whether any database modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Defines if the RDS instance will be protected to accidental deletion"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Defines if the RDS instance will be publicly accessible"
  type        = bool
  default     = false
}

variable "rds_bkp_retention" {
  description = "The days to retain database backups"
  type        = number
  default     = 7
}

variable "rds_bkp_window" {
  description = "The daily time range (in UTC) during which automated backups are created"
  type        = string
  default     = "01:00-02:30"
}

variable "rds_main_window" {
  description = "The time range (in UTC) to perform maintenance in the RDS database"
  type        = string
  default     = "wed:03:05-wed:03:35"
}

variable "rds_final_snapshot" {
  description = "Defines if the RDS instance will skip a final snapshot after deletion (true skips and false does it)"
  type        = bool
  default     = true
}

variable "rds_final_snapshot_id" {
  description = "The name of your final DB snapshot when this DB instance is deleted. Must be provided if skip_final_snapshot is set to false"
  type        = string
  default     = "hrmdb-staging-final-snapshot"
}

variable "cw_logs_export" {
  description = "List of Postgresql values to add to CloudWatch"
  type        = list(string)
  default     = ["postgresql", "upgrade"]
}

/*==== Monitoring module variables ======*/
variable "sns_subscription_email_address_list" {
  description = "List of email addresses as string(space separated)"
  type = string
  default = "aselo-alerts@techmatters.org"
}

variable "sns_subscription_phone_number_list" {
  description = "List of phone numbers for SMS alerts"
  type = list(string)
  default = [""]
}

variable "hrm_public_dns" {
  description = "Public name to access HRM application. E.G: hrm-staging.tl.techmatters.org"
  type        = string
  default     = "hrm-test.tl.techmatters.org"
}

variable "chat_public_dns" {
  description = "Public name to access Web Chat. E.G: chat-staging.tl.techmatters.org"
  type        = string
  default     = "chat-test.tl.techmatters.org"
}

variable "flex_public_dns" {
  description = "Public name to access Twilio Flex. E.G: flex.twilio.com"
  type        = string
  default     = "flex.twilio.com"
}