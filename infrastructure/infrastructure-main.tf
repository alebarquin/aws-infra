/*==== Infrastructure environment main provision script ======*/

/*==== Cloud provider ======*/
provider "aws" {
  region  = var.region
  # access_key  = "Your.Access.Key.Value" ### OPTIONAL, if no AWS CLI profile is configured
  # secret_key  = "Your.Secret.Key.Value" ### OPTIONAL, if no AWS CLI profile is configured
}

/*==== Terraform setup to use remote state file (s3 bucket and DynamoDB table must be created befor use this feature) ======*/
terraform {
  backend "s3" {
    bucket         = "tl-terraform-state-infrastructure"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "infrastructure-terraform-locks"
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

/*==== Call VPC module ======*/
module "vpc" {
source = "./vpc"
  region                 = var.region
  environment            = var.environment
  vpc_cidr               = var.vpc_cidr
  public_subnet_cidr     = var.public_subnet_cidr
  availability_zone      = var.availability_zone
}

/*==== Call CertServer module ======*/
module "certserver" {
source = "./certserver"
  region                 = var.region
  environment            = var.environment
  availability_zone      = var.availability_zone
  ami                    = var.ami
  ec2_instance_type      = var.ec2_instance_type
  vpc_id                 = module.vpc.vpc_id
  public_subnet_id       = module.vpc.public_subnet
}