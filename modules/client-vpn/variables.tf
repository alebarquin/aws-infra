/*==== Input variable definitions ======*/

variable "region" {
  description = "AWS Deployment region"
  type        = string
}

variable "environment" {
  description = "Name of the environment to provision"
  type        = string
}

variable "dest_vpc_id" {
  description = "The ID of the VPC to associate with the Client VPN endpoint. Get this value from AWS VPC console"
  type        = string
}

variable "dest_subnet_id" {
  description = "The ID of the subnet to associate with the Client VPN endpoint. Get these values from the AWS VPC/Subnets console (they must belong to the associated VPC)"
  type        = list(string)
}

variable "server_cert" {
  description = "VPN Server certificate ARN. Get this value from AWS Certificate Manager console"
  type        = string
}

variable "client_cert" {
  description = "VPN Client certificate ARN. Get this value from AWS Certificate Manager console"
  type        = string
}

variable "vpn_log_retention" {
  description = "Days for VPN log retention"
  type        = string
}

variable "client_cidr_block" {
  description = "The CIDR block to assign to VPN clients. Must be different from VPC CIDR or any route in VPC route table"
  type        = string
}

variable "dest_vpc_cidr_block" {
  description = "The CIDR block of the VPC to associate with VPN"
  type        = string
}

variable "split_tunnel" {
  description = "Pushes the route table of the VPN endpoint to the client so that only part of the traffic goes through the VPN endpoint. Values: true or false"
  type        = bool
}

variable "dns_servers" {
  description = "List of DNS servers to be used by the VPN endpoint"
  type        = list(string)
}