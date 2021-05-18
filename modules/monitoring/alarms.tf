/*==== RDS database alarms ======*/
/*==== CPU too high ======*/
resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization_too_high" {
  alarm_name          = "${var.environment}-hrmdb_cpu_utilization_too_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "95"
  alarm_description   = "${var.environment} - Average database CPU utilization over last 10 minutes too high"
  alarm_actions       = [aws_sns_topic.aws_alarms.arn]
  ok_actions          = [aws_sns_topic.aws_alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

/*==== CPU too high - Low Urgency ======*/
resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization_too_high_low_urgency" {
  alarm_name          = "${var.environment}-hrmdb_cpu_utilization_too_high_low_urgency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "${var.environment} - LOW URGENCY - Average database CPU utilization over last 10 minutes too high"
  alarm_actions       = [aws_sns_topic.aws_alarms.arn]
  ok_actions          = [aws_sns_topic.aws_alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

/*==== Free memory too low ======*/
resource "aws_cloudwatch_metric_alarm" "rds_freeable_memory_too_low" {
  alarm_name          = "${var.environment}-hrmdb_freeable_memory_too_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "64000000"
  alarm_description   = "${var.environment} - Average database freeable memory over last 10 minutes too low, performance may suffer"
  alarm_actions       = [aws_sns_topic.aws_alarms.arn]
  ok_actions          = [aws_sns_topic.aws_alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

/*==== Free memory too low - Low Urgency ======*/
resource "aws_cloudwatch_metric_alarm" "rds_freeable_memory_too_low_low_urgency" {
  alarm_name          = "${var.environment}-hrmdb_freeable_memory_too_low_low_urgency"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "128000000"
  alarm_description   = "${var.environment} - LOW URGENCY - Average database freeable memory over last 10 minutes too low, performance may suffer"
  alarm_actions       = [aws_sns_topic.aws_alarms.arn]
  ok_actions          = [aws_sns_topic.aws_alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

/*==== Free storage too low ======*/
resource "aws_cloudwatch_metric_alarm" "rds_free_storage_space_too_low" {
  alarm_name          = "${var.environment}-hrmdb_free_storage_space_threshold"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "2000000000"
  alarm_description   = "${var.environment} - Average database free storage space over last 10 minutes too low"
  alarm_actions       = [aws_sns_topic.aws_alarms.arn]
  ok_actions          = [aws_sns_topic.aws_alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

/*==== Free storage too low - Low Urgency ======*/
resource "aws_cloudwatch_metric_alarm" "rds_free_storage_space_too_low_low_urgency" {
  alarm_name          = "${var.environment}-hrmdb_free_storage_space_threshold_low_urgency"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "4000000000"
  alarm_description   = "${var.environment} - LOW URGENCY - Average database free storage space over last 10 minutes too low"
  alarm_actions       = [aws_sns_topic.aws_alarms.arn]
  ok_actions          = [aws_sns_topic.aws_alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

/*==== Number of connections too high ======*/
resource "aws_cloudwatch_metric_alarm" "rds_connections_too_high_low_urgency" {
  alarm_name          = "${var.environment}-hrmdb_connections_too_high_low_urgency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "${var.environment} - LOW URGENCY - The number of connections to RDS instance is reaching the maximum"
  alarm_actions       = [aws_sns_topic.aws_alarms.arn]
  ok_actions          = [aws_sns_topic.aws_alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

/*==== Number of connections too high - Low Urgency ======*/
resource "aws_cloudwatch_metric_alarm" "rds_connections_too_high" {
  alarm_name          = "${var.environment}-hrmdb_connections_too_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "95"
  alarm_description   = "${var.environment} - The number of connections to RDS instance is reaching the maximum"
  alarm_actions       = [aws_sns_topic.aws_alarms.arn]
  ok_actions          = [aws_sns_topic.aws_alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

/*==== ECS cluster alarms ======*/
/*==== CPU too high ======*/
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_utilization_too_high" {
  alarm_name          = "${var.environment}-ecs-cluster_cpu_utilization_too_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "600"
  statistic           = "Average"
  threshold           = "95"
  alarm_description   = "${var.environment} - Average ECS cluster CPU utilization over last 10 minutes too high"
  alarm_actions       = [aws_sns_topic.aws_alarms.arn]
  ok_actions          = [aws_sns_topic.aws_alarms.arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
}

/*==== Memory usage too high ======*/
resource "aws_cloudwatch_metric_alarm" "ecs_memory_utilization_too_high" {
  alarm_name          = "${var.environment}-ecs-cluster_memory_utilization_too_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "600"
  statistic           = "Average"
  threshold           = "960000000"
  alarm_description   = "${var.environment} - Average ECS cluster Memory Utilization over last 10 minutes too high, performance may suffer"
  alarm_actions       = [aws_sns_topic.aws_alarms.arn]
  ok_actions          = [aws_sns_topic.aws_alarms.arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
}

/*==== Public URL checks alarms ======*/
/*==== HRM checks alarms ======*/
resource "aws_cloudwatch_metric_alarm" "r53_hrm_alarm" {
  alarm_name          = "${var.environment}-r53_hrm_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "600"
  statistic           = "Minimum"
  threshold           = "0"
  alarm_description   = "${var.environment} - HRM public URL is not responding"
  alarm_actions       = [aws_sns_topic.aws_alarms.arn]
  ok_actions          = [aws_sns_topic.aws_alarms.arn]
  dimensions = {
    HealthCheckId     = aws_route53_health_check.r53_hrm.id
  }
}

/*==== Web Chat checks alarms ======*/
resource "aws_cloudwatch_metric_alarm" "r53_chat_alarm" {
  alarm_name          = "${var.environment}-r53_chat_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "600"
  statistic           = "Minimum"
  threshold           = "0"
  alarm_description   = "${var.environment} - Web Chat public URL is not responding"
  alarm_actions       = [aws_sns_topic.aws_alarms.arn]
  ok_actions          = [aws_sns_topic.aws_alarms.arn]
  dimensions = {
    HealthCheckId     = aws_route53_health_check.r53_chat.id
  }
}

/*==== Flex checks alarms ======*/
resource "aws_cloudwatch_metric_alarm" "r53_flex_alarm" {
  alarm_name          = "${var.environment}-r53_flex_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "600"
  statistic           = "Minimum"
  threshold           = "0"
  alarm_description   = "${var.environment} - Twilio Flex public URL is not responding"
  alarm_actions       = [aws_sns_topic.aws_alarms.arn]
  ok_actions          = [aws_sns_topic.aws_alarms.arn]
  dimensions = {
    HealthCheckId     = aws_route53_health_check.r53_flex.id
  }
}