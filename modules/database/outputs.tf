output "db_instance_id" {
  description = "The ID of the RDS database instance"
  value       = aws_db_instance.rds_instance.id
}