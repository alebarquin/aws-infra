/*==== Staging environment main provision script ======*/

/*==== Cloud provider ======*/
provider "aws" {
  region  = var.region
  # access_key  = "Your.Access.Key.Value" ### OPTIONAL, if no AWS CLI profile is configured
  # secret_key  = "Your.Secret.Key.Value" ### OPTIONAL, if no AWS CLI profile is configured
}

/*==== Terraform setup to use remote state file ======*/
terraform {
  backend "s3" {
    bucket         = "tl-terraform-state-staging"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "staging-terraform-locks"
    encrypt        = true
  }
}

/*==== S3 bucket to store terraform state ======*/
resource "aws_s3_bucket" "terraform_state" {
  bucket = "tl-terraform-state-${var.environment}"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = {
    Name        = "tl-terraform-state-${var.environment}"
    Environment = var.environment
  }
}

/*==== DynamoDB table for terraform locking state ======*/
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.environment}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name        = "${var.environment}-terraform-locks"
    Environment = var.environment
  }
}

/*==== Call Networking module ======*/
module "networking" {
source = "../modules/networking"
  region                 = var.region
  environment            = var.environment
  vpc_cidr               = var.vpc_cidr
  public_subnets_cidr    = var.public_subnets_cidr
  private_subnets_cidr   = var.private_subnets_cidr
  database_subnets_cidr  = var.database_subnets_cidr
  availability_zones     = var.availability_zones
}

/*==== Call Client-VPN module ======*/
module "client-vpn" {
source = "../modules/client-vpn"
  region                 = var.region
  environment            = var.environment
  server_cert            = var.server_cert
  client_cert            = var.client_cert
  vpn_log_retention      = var.vpn_log_retention
  client_cidr_block      = var.client_cidr_block
  split_tunnel           = var.split_tunnel
  dns_servers            = var.dns_servers
  dest_vpc_id            = module.networking.vpc_id
  dest_subnet_id         = module.networking.database_subnets
  dest_vpc_cidr_block    = module.networking.vpc_cidr_block
}

/*==== Call Serverless module ======*/
module "serverless" {
source = "../modules/serverless"
  region                 = var.region
  environment            = var.environment
  application            = var.application
  alb_tls_cert_arn       = var.alb_tls_cert_arn
  s3_variables           = var.s3_variables
  container_port         = var.container_port
  container_image        = var.container_image
  dns_zone_id            = var.dns_zone_id
  dns_public             = var.dns_public
  api_log_retention      = var.api_log_retention
  vpc_id                 = module.networking.vpc_id
  public_subnets_id      = module.networking.public_subnets
  private_subnets_id     = module.networking.private_subnets
  public_subnets_cidr    = module.networking.public_subnets_cidr_blocks
  client_vpn_sg_id       = module.client-vpn.client_vpn_sg_id
}

/*==== Call Database module ======*/
module "database" {
source = "../modules/database"
  region                        = var.region
  environment                   = var.environment
  s3_backups                    = var.s3_backups
  dns_zone_id                   = var.dns_zone_id
  dns_rds                       = var.dns_rds
  rds_allocated_storage         = var.rds_allocated_storage
  rds_max_allocated_storage     = var.rds_max_allocated_storage
  rds_storage_type              = var.rds_storage_type
  rds_database_port             = var.rds_database_port
  rds_engine                    = var.rds_engine
  rds_engine_version            = var.rds_engine_version
  rds_instance_class            = var.rds_instance_class
  rds_multi_az                  = var.rds_multi_az
  rds_database_name             = var.rds_database_name
  rds_user                      = var.rds_user
  rds_master_password           = var.rds_master_password
  rds_ca                        = var.rds_ca
  # rds_snapshot_id               = var.rds_snapshot_id
  rds_apply_immediately         = var.rds_apply_immediately
  rds_bkp_retention             = var.rds_bkp_retention
  rds_bkp_window                = var.rds_bkp_window
  rds_main_window               = var.rds_main_window
  deletion_protection           = var.deletion_protection
  publicly_accessible           = var.publicly_accessible
  rds_final_snapshot            = var.rds_final_snapshot
  rds_final_snapshot_id         = var.rds_final_snapshot_id
  cw_logs_export                = var.cw_logs_export
  vpc_id                        = module.networking.vpc_id
  database_subnets_id           = module.networking.database_subnets
  private_subnets_cidr          = module.networking.private_subnets_cidr_blocks
  client_vpn_sg_id              = module.client-vpn.client_vpn_sg_id
}

/*==== Call Monitoring module ======*/
module "monitoring" {
source = "../modules/monitoring"
  region                                = var.region
  environment                           = var.environment
  sns_subscription_email_address_list   = var.sns_subscription_email_address_list
  sns_subscription_phone_number_list    = var.sns_subscription_phone_number_list
  hrm_public_dns                        = var.hrm_public_dns
  chat_public_dns                       = var.chat_public_dns
  flex_public_dns                       = var.flex_public_dns
  db_instance_id                        = module.database.db_instance_id
  ecs_cluster_name                      = module.serverless.ecs_cluster_name
  ecs_service_name                      = module.serverless.ecs_service_name
}