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
