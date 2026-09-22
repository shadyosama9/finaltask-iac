output "task_definition_arns" {
  description = "Task definition ARNs keyed by task definition map key, without revision suffixes"
  value = {
    for key, task_definition in aws_ecs_task_definition.this :
    key => task_definition.arn_without_revision
  }
}

output "ecs_service_arns" {
  description = "ECS service ARNs keyed by service map key"
  value = {
    for key, service in aws_ecs_service.this :
    key => service.arn
  }
}

output "ecs_service_names" {
  description = "ECS service names"
  value = { for key, service in aws_ecs_service.this : key => service.name }
}

output "ecs_cluster_names" {
  description = "ECS cluster names used by the services"
  value = { for key, service in aws_ecs_service.this : key => split("/", service.cluster)[1] }
}