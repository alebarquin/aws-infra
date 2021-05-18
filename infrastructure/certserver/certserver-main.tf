/*==== VPC module ======*/
terraform {
  required_version = ">= 0.12"
}

/*==== Cloud provider ======*/
provider "aws" {
  region  = var.region
}

/*==== SSH Key pair ======*/
resource "tls_private_key" "priv_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.environment}-certificate-server-key"
  public_key = tls_private_key.priv_key.public_key_openssh
}

/*==== Security groups ======*/
/*==== Certificate server - SG ======*/
resource "aws_security_group" "cert_server" {
  name   = "${var.environment}-certificate-server-sg"
  vpc_id = var.vpc_id
 

  ingress {
   protocol         = "tcp"
   from_port        = 22
   to_port          = 22
   cidr_blocks      = ["0.0.0.0/0"]
  }
 
  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
   Name        = "${var.environment}-certificate-server-sg"
   Environment = var.environment
  }
}

/*==== Certificate server instance ======*/
resource "aws_instance" "cert_server" {
  ami                           = var.ami
  availability_zone             = var.availability_zone
  subnet_id                     = var.public_subnet_id
  instance_type                 = var.ec2_instance_type
  key_name                      = aws_key_pair.generated_key.key_name
  vpc_security_group_ids        = [aws_security_group.cert_server.id]
  associate_public_ip_address   = true
  tags = {
    Name        = "${var.environment}-certificate-server"
    Environment = var.environment
  }
  root_block_device  {
    volume_size             = 20
    volume_type             = "gp2"
    encrypted               = true
    delete_on_termination   = true
    tags = {
      Name      = "${var.environment}-certificate-server - /dev/sda1"
    }
  }
}

/*==== Elastic IPs for Certificate server ======*/
resource "aws_eip" "ec2_eip" {
  vpc           = true
  instance      = aws_instance.cert_server.id
  tags = {
    Name        = "${var.environment}-certificate-server-public-ip"
    Environment = var.environment
  }
}