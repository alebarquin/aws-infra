/*==== Development environment main provision script ======*/

/*==== Cloud provider ======*/
provider "aws" {
  region  = var.region
  # access_key  = "Your.Access.Key.Value" ### OPTIONAL, if no AWS CLI profile is configured
  # secret_key  = "Your.Secret.Key.Value" ### OPTIONAL, if no AWS CLI profile is configured
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