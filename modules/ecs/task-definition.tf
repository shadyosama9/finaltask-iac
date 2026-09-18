resource "aws_cloudwatch_log_group" "ecs_log_group" {
  for_each = var.cloudwatch_group

  name              = "/aws/ecs/${each.value.name}/logs"
  retention_in_days = each.value.retention_in_days

  tags = var.tags
}

resource "aws_ecs_task_definition" "this" {
  for_each = var.task_definition

  family                   = each.value.family
  execution_role_arn       = each.value.execution_role_arn
  task_role_arn            = each.value.task_role_arn
  requires_compatibilities = each.value.requires_compatibilities
  network_mode             = each.value.network_mode
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  dynamic "ephemeral_storage" {
    for_each = try(each.value.ephemeral_storage[*], [])

    content {
      size_in_gib = ephemeral_storage.value.size_in_gib
    }
  }

  dynamic "volume" {
    for_each = lookup(each.value, "volumes", [])

    content {
      name = volume.value.name
    }
  }
  container_definitions = jsonencode([
    for container in each.value.container_definitions : {
      name      = container.name
      image     = container.image
      cpu       = container.cpu
      memory    = container.memory
      essential = container.essential
      command   = container.command

      mountPoints = [
        for mount in lookup(container, "mountPoints", []) : {
          sourceVolume  = mount.sourceVolume
          containerPath = mount.containerPath
        }
      ]

      portMappings = [
        for mapping in lookup(container, "port_mappings", []) : {
          containerPort = mapping.container_port
          hostPort      = mapping.host_port
        }
      ]

      secrets = [
        for secret in lookup(container, "secrets", []) : {
          name      = secret.name
          valueFrom = secret.value_from
        }
      ]

      logConfiguration = {
        logDriver = container.log_configuration.log_driver
        options = {
          awslogs-group         = "/aws/ecs/${var.cloudwatch_group[container.log_configuration.options.awslogs_group].name}/logs"
          awslogs-region        = container.log_configuration.options.awslogs_region
          awslogs-stream-prefix = container.log_configuration.options.awslogs_stream_prefix
        }
      }
    }
  ])

  lifecycle {
    ignore_changes = [
      container_definitions,
      tags,
      tags_all
    ]
  }
}