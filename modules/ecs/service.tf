resource "aws_ecs_service" "this" {
  for_each = var.ecs_services

  name            = each.value.name
  cluster         = aws_ecs_cluster.this[each.value.cluster_key].id
  launch_type     = "FARGATE"
  desired_count   = each.value.desired_count
  task_definition = aws_ecs_task_definition.this[each.value.task_definition_key].arn

  force_new_deployment               = each.value.force_new_deployment
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  enable_execute_command = true

  dynamic "network_configuration" {
    for_each = each.value.network_configuration
    content {
      assign_public_ip = network_configuration.value.assign_public_ip
      subnets          = network_configuration.value.subnet_ids
      security_groups  = network_configuration.value.security_group_ids
    }
  }
  
  dynamic "load_balancer" {
    for_each = each.value.load_balancer
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  tags            = merge(var.tags, each.value.tags)
  lifecycle {
    ignore_changes = [task_definition]
  }
}