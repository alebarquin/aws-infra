/*==== Database module ======*/
terraform {
  required_version = ">= 0.12"
}

/*==== Cloud provider ======*/
provider "aws" {
  region  = var.region
}

/*==== RDS database - SG ======*/
resource "aws_security_group" "rds_sg" {
  name   = "${var.environment}-database-sg"
  vpc_id = var.vpc_id
 
  ingress {
   protocol         = "tcp"
   from_port        = var.rds_database_port
   to_port          = var.rds_database_port
   cidr_blocks      = var.private_subnets_cidr
  }

  ingress {
   protocol         = "tcp"
   from_port        = var.rds_database_port
   to_port          = var.rds_database_port
   security_groups  = var.client_vpn_sg_id
  }
 
  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
   Name        = "${var.environment}-database-sg"
   Environment = var.environment
  }
}

/*==== RDS Subnet group ======*/
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.environment}-subnet-group"
  subnet_ids = var.database_subnets_id
}

/*==== IAM policy for RDS backups ======*/
resource "aws_iam_policy" "s3_backup_policy" {
  name        = "AmazonS3RDSBackup_${var.environment}"
  description = "Provide write access from RDS SQL Server in ${var.environment} to bucket ${var.s3_backups} for backups."

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": "s3:ListAllMyBuckets",
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"s3:ListBucket",
				"s3:GetBucketACL",
				"s3:GetBucketLocation"
			],
			"Resource": "arn:aws:s3:::${var.s3_backups}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"s3:PutObject",
				"s3:GetObject",
				"s3:GetLifecycleConfiguration",
				"s3:ListMultipartUploadParts",
				"s3:PutLifecycleConfiguration",
				"s3:AbortMultipartUpload"
			],
			"Resource": [
				"arn:aws:s3:::${var.s3_backups}",
				"arn:aws:s3:::${var.s3_backups}/*"
			]
		}
	]
}
EOF
}

/*==== Role for RDS backups ======*/
resource "aws_iam_role" "rds_backups_role" {
  name = "${var.environment}-rds-backups-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "rds.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

/*==== Attach policy to role ======*/
resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = aws_iam_role.rds_backups_role.name
  policy_arn = aws_iam_policy.s3_backup_policy.arn
}

/*==== RDS database instance ======*/
resource "aws_db_instance" "rds_instance" {
  allocated_storage                = var.rds_allocated_storage
  max_allocated_storage            = var.rds_max_allocated_storage
  storage_type                     = var.rds_storage_type
  engine                           = var.rds_engine
  engine_version                   = var.rds_engine_version
  instance_class                   = var.rds_instance_class
  vpc_security_group_ids           = [aws_security_group.rds_sg.id]
  db_subnet_group_name             = aws_db_subnet_group.rds_subnet_group.name
  multi_az                         = var.rds_multi_az
  identifier                       = "${var.environment}-${var.rds_engine}-rds"
  name                             = var.rds_database_name
  username                         = var.rds_user
  password                         = var.rds_master_password
  port                             = var.rds_database_port
  deletion_protection              = var.deletion_protection
  ca_cert_identifier               = var.rds_ca
  copy_tags_to_snapshot            = true
  performance_insights_enabled     = true
  apply_immediately                = var.rds_apply_immediately
  allow_major_version_upgrade      = true
  publicly_accessible              = var.publicly_accessible
  storage_encrypted                = true
  backup_retention_period          = var.rds_bkp_retention
  backup_window                    = var.rds_bkp_window
  maintenance_window               = var.rds_main_window
  skip_final_snapshot              = var.rds_final_snapshot
  final_snapshot_identifier        = var.rds_final_snapshot_id
  enabled_cloudwatch_logs_exports  = var.cw_logs_export
  # snapshot_identifier              = var.rds_snapshot_id
}

/*==== RDS DNS record ======*/
resource "aws_route53_record" "dns" {
  zone_id = var.dns_zone_id
  name    = var.dns_rds
  type    = "CNAME"
  ttl     = "60"
  records = [aws_db_instance.rds_instance.address]
}