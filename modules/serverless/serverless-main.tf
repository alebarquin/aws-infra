/*==== Serverless module ======*/
terraform {
  required_version = ">= 0.12"
}

/*==== Cloud provider ======*/
provider "aws" {
  region  = var.region
}

/*==== Security groups ======*/
/*==== Aplication Load Balancer - SG ======*/
resource "aws_security_group" "alb" {
  name   = "${var.environment}-alb-sg"
  vpc_id = var.vpc_id
 
   ingress {
   protocol         = "tcp"
   from_port        = 80
   to_port          = 80
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
   protocol         = "tcp"
   from_port        = 443
   to_port          = 443
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }
 
  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
   Name        = "${var.environment}-${var.application}-alb-sg"
   Environment = var.environment
  }
}

/*==== ECS Tasks - SG ======*/
resource "aws_security_group" "ecs_tasks" {
  name   = "${var.environment}-ecs-tasks-sg"
  vpc_id = var.vpc_id
 
  ingress {
   protocol         = "tcp"
   from_port        = var.container_port
   to_port          = var.container_port
   cidr_blocks      = var.public_subnets_cidr
  }

  ingress {
   protocol         = "tcp"
   from_port        = var.container_port
   to_port          = var.container_port
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
   Name        = "${var.environment}-${var.application}-ecs-tasks-sg"
   Environment = var.environment
  }
}

/*==== Application load balancer for HRM ======*/
resource "aws_lb" "alb" {
  name               = "${var.environment}-${var.application}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnets_id
  enable_deletion_protection = false
  tags = {
   Name        = "${var.environment}-${var.application}-alb"
   Environment = var.environment
  }
}
 
resource "aws_alb_target_group" "tg" {
  name                  = "${var.environment}-${var.application}-tg"
  port                  = var.container_port
  protocol              = "HTTP"
  vpc_id                = var.vpc_id
  target_type           = "ip"
  deregistration_delay  = 30
 
  health_check {
   healthy_threshold   = "5"
   interval            = "30"
   protocol            = "HTTP"
   matcher             = "200"
   timeout             = "3"
   path                = "/"
   unhealthy_threshold = "2"
  }

  depends_on  = [aws_lb.alb]
}

/*
  resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
 
  default_action {
   type = "redirect"
 
   redirect {
     port        = 443
     protocol    = "HTTPS"
     status_code = "HTTP_301"
   }
  }
}
*/
 
resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn   = var.alb_tls_cert_arn
 
  default_action {
    target_group_arn = aws_alb_target_group.tg.id
    type             = "forward"
  }
}

/*==== ALB public DNS ======*/
resource "aws_route53_record" "dns" {
  zone_id = var.dns_zone_id
  name    = var.dns_public
  type    = "CNAME"
  ttl     = "60"
  records = [aws_lb.alb.dns_name]
}

/*==== Elastic Container Registry ======*/
resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.environment}-${var.application}"
  image_tag_mutability = "MUTABLE"
}

/*==== ECR lifecycle policy ======*/
resource "aws_ecr_lifecycle_policy" "ecr_policy" {
  repository = aws_ecr_repository.app_repo.name
 
  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep image deployed with tag latest",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["latest"],
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "keep last 30 images for ${var.application}",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 30
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

/*==== AWS Cloudwatch log group for HRM ======*/
resource "aws_cloudwatch_log_group" "hrm_api" {
  name = "${var.environment}-${var.application}-awslogs"
  retention_in_days = var.api_log_retention

  tags = {
    Environment = var.environment
    Application = var.application
  }
}


/*==== Elastic Container Service cluster ======*/
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.environment}-ecs-cluster"
}

/*==== ECS tasks definition ======*/
resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "${var.environment}-${var.application}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions =<<DEFINITION
  [
    {
      "name": "${var.environment}-${var.application}-container",
      "image": "${local.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/${local.repository_name}:latest",
      "networkMode": "awsvpc",
      "command": ["npm", "start"],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group" : "${aws_cloudwatch_log_group.hrm_api.name}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "${var.environment}-${var.application}-service"
        }
      },
      "environmentFiles": [
        {
        "value": "arn:aws:s3:::${var.s3_variables}/${var.environment}.env",
        "type": "s3"
        }
      ],
      "portMappings": [
        {
        "protocol": "tcp",
        "containerPort": ${var.container_port},
        "hostPort": ${var.container_port}
        }
      ]
    }
  ]
  DEFINITION
  tags = {
    Name ="${var.environment}-${var.application}-ecs-task"
    Environment = var.environment
  }
}

/*==== ECS task role ======*/
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.environment}-ecsTaskRole"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

/*==== ECS task execution role ======*/
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.environment}-ecsTaskExecutionRole"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

/*==== IAM Policy to pull variables from S3 bucket ======*/ 
resource "aws_iam_policy" "s3_var_policy" {
  name        = "${var.environment}-s3-var-policy"
  description = "Policy that allows access to variables in s3 bucket"
 
 policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "s3:GetObject"
           ],
           "Resource": "arn:aws:s3:::${var.s3_variables}/${var.environment}.env"
       },
       {
           "Effect": "Allow",
           "Action": [
               "s3:GetBucketLocation"
           ],
           "Resource": "arn:aws:s3:::${var.s3_variables}"
       }
   ]
}
EOF
}

/*==== ECS Policy attachtment to execution role ======*/ 
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

/*==== S3 Policy attachtment to execution role ======*/ 
resource "aws_iam_role_policy_attachment" "ecs-task-execution-s3-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.s3_var_policy.arn
}

/*==== ECS service definitions ======*/
resource "aws_ecs_service" "ecs_service" {
 depends_on                         = [aws_alb_target_group.tg]
 name                               = "${var.environment}-ecs-service"
 cluster                            = aws_ecs_cluster.ecs_cluster.id
 task_definition                    = aws_ecs_task_definition.ecs_task.arn
 desired_count                      = 2
 deployment_minimum_healthy_percent = 50
 deployment_maximum_percent         = 200
 launch_type                        = "FARGATE"
 scheduling_strategy                = "REPLICA"
 platform_version                   = "1.4.0"
 
 network_configuration {
   security_groups  = [aws_security_group.ecs_tasks.id]
   subnets          = var.private_subnets_id
   assign_public_ip = false
 }
 
 load_balancer {
   target_group_arn = aws_alb_target_group.tg.arn
   container_name   = "${var.environment}-${var.application}-container"
   container_port   = var.container_port
 }
 
 lifecycle {
   ignore_changes = [task_definition, desired_count]
 }
   tags = {
    Name ="${var.environment}-ecs-service"
    Environment = var.environment
  }
}

/*==== Tasks autoscaling definitions ======*/
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
 
  target_tracking_scaling_policy_configuration {
   predefined_metric_specification {
     predefined_metric_type = "ECSServiceAverageMemoryUtilization"
   }
 
   target_value       = 95
  }
}
 
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
 
  target_tracking_scaling_policy_configuration {
   predefined_metric_specification {
     predefined_metric_type = "ECSServiceAverageCPUUtilization"
   }
 
   target_value       = 95
  }
}