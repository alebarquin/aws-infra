/*==== VPN module ======*/
terraform {
  required_version = ">= 0.12"
}

/*==== Cloud provider ======*/
provider "aws" {
  region  = var.region
}

/*==== Security groups ======*/
/*==== Client VPN - SG ======*/
resource aws_security_group "client-vpn-sg" {
  name   = "${var.environment}-client-vpn-sg"
  vpc_id = var.dest_vpc_id

  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
   Name        = "${var.environment}-client-vpn-sg"
   Environment = var.environment
  }
}

/*==== AWS Cloudwatch log group for VPN connections ======*/
resource "aws_cloudwatch_log_group" "client_vpn_logs" {
  name              = "${var.environment}-client-vpn-awslogs"
  retention_in_days = var.vpn_log_retention

  tags = {
    Name        = "${var.environment}-client-vpn-awslogs"
    Environment = var.environment
  }
}

/*==== AWS Client VPN ======*/
/*==== VPN Endpoint ======*/
resource "aws_ec2_client_vpn_endpoint" "client-vpn-endpoint" {
  description            = "${var.environment}-client-vpn-endpoint"
  server_certificate_arn = var.server_cert
  client_cidr_block      = var.client_cidr_block
  split_tunnel           = var.split_tunnel
  dns_servers            = var.dns_servers

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.client_cert
  }

  connection_log_options {
    enabled              = true
    cloudwatch_log_group = aws_cloudwatch_log_group.client_vpn_logs.name
  }

  tags = {
    Name        = "${var.environment}-client-vpn-endpoint"
    Environment = var.environment
  }
}

/*==== VPN Network association ======  # Enable this resource if you are going to keep the VPN endpoints always available.
resource "aws_ec2_client_vpn_network_association" "client-vpn-network-association" {
  count                  = length(var.dest_subnet_id)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn-endpoint.id
  subnet_id              = element(var.dest_subnet_id, count.index)
}*/

/*==== VPN routes ======  # Enable this resource if you want to allow internet access through VPN client endpoint.
resource "aws_ec2_client_vpn_route" "client-vpn-route" {
  count                  = length(var.dest_subnet_id)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn-endpoint.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   = element(var.dest_subnet_id, count.index)
  description            = "Internet Access"

  depends_on = [
    aws_ec2_client_vpn_endpoint.client-vpn-endpoint,
    aws_ec2_client_vpn_network_association.client-vpn-network-association
  ]
}*/

/*==== Authorize VPN access ======*/
resource "null_resource" "authorize-client-vpn-ingress" {
  provisioner "local-exec" {
    when    = create
    command = "aws --region ${var.region} ec2 authorize-client-vpn-ingress --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.client-vpn-endpoint.id} --target-network-cidr ${var.dest_vpc_cidr_block} --authorize-all-groups"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_ec2_client_vpn_endpoint.client-vpn-endpoint,
    /*aws_ec2_client_vpn_network_association.client-vpn-network-association*/
  ]
}

/*==== Attach VPN security group ======*/
resource null_resource "client-vpn-security-group" {
  provisioner "local-exec" {
    when    = create
    command = "aws ec2 apply-security-groups-to-client-vpn-target-network --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.client-vpn-endpoint.id} --vpc-id ${aws_security_group.client-vpn-sg.vpc_id} --security-group-ids ${aws_security_group.client-vpn-sg.id}"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_ec2_client_vpn_endpoint.client-vpn-endpoint,
    aws_security_group.client-vpn-sg
  ]
}