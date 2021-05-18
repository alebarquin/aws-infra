/*==== Networking module ======*/
terraform {
  required_version = ">= 0.12"
}

/*==== Cloud provider ======*/
provider "aws" {
  region  = var.region
}

/*==== The VPC ======*/
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

/*==== Subnets ======*/
/* Internet gateway for the public subnets */
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

/* Elastic IPs for NATs */
resource "aws_eip" "nat_eip" {
  count      = length(var.availability_zones)
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
  tags = {
    Name        = "${var.environment}-nat-${element(var.availability_zones, count.index)}"
    Environment = var.environment
  }
}

/* NAT Gateways for private subnets */
resource "aws_nat_gateway" "nat" {
  count         = length(var.availability_zones)
  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "${var.environment}-nat-${element(var.availability_zones, count.index)}"
    Environment = var.environment
  }
}

/* Public subnets */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr,   count.index)
  availability_zone       = element(var.availability_zones,   count.index)
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-public-subnet"
    Environment = var.environment
  }
}

/* Private subnets */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones,   count.index)
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-private-subnet"
    Environment = var.environment
  }
}

/* Database private subnets */
resource "aws_subnet" "database_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.database_subnets_cidr)
  cidr_block              = element(var.database_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones,   count.index)
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-database-subnet"
    Environment = var.environment
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  count         = length(var.availability_zones)
  vpc_id        = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-private-route-table"
    Environment = var.environment
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id        = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = var.environment
  }
}

/* Routing table for database subnet */
resource "aws_route_table" "database" {
  count         = length(var.availability_zones)
  vpc_id        = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-database-route-table"
    Environment = var.environment
  }
}

/* Routes for public and private subnets */
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route" "private_nat_gateway" {
  count                  = length(var.private_subnets_cidr)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat.*.id, count.index)
}

/* Route table associations */
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "database" {
  count          = length(var.database_subnets_cidr)
  subnet_id      = element(aws_subnet.database_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.database.*.id, count.index)
}