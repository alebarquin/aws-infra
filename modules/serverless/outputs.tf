output "ecs_cluster_name" {
  description = "The name of the created ECS cluster"
  value       = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_service_name" {
  description = "The name of the created ECS service"
  value       = aws_ecs_service.ecs_service.name
}