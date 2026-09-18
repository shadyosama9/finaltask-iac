variable "cloudwatch_group" {
  description = "Map of CloudWatch log group configurations for ECS tasks"
  type = map(object({
    name              = string
    retention_in_days = number
  }))

  default = {}
}

variable "tags" {
  type = map(any)
}

variable "ecs" {
  description = "Map of ECS clusters to create"
  type = map(object({
    name = string
    tags = optional(map(string), {})
  }))
}

variable "task_definition" {
  description = "Map of ECS task definition configurations"
  type = map(object({
    family                   = string
    requires_compatibilities = list(string)
    network_mode             = string
    cpu                      = number
    memory                   = number
    execution_role_arn       = string
    task_role_arn            = string

    ephemeral_storage = optional(object({
      size_in_gib = optional(number, 0)
    }))

    volumes = optional(list(object({
      name = string
    })), [])

    container_definitions = list(object({
      name      = string
      image     = string
      cpu       = number
      memory    = number
      essential = bool
      command   = optional(list(string), [])

      port_mappings = optional(
        list(object({
          container_port = number
          host_port      = number
        })),
        []
      )

      log_configuration = object({
        log_driver = string

        options = object({
          awslogs_group         = string
          awslogs_region        = string
          awslogs_stream_prefix = string
        })
      })

      secrets = optional(
        list(object({
          name       = string
          value_from = string
        })),
        []
      )

      mountPoints = optional(list(object({
        sourceVolume  = string
        containerPath = string
      })), [])
    }))
  }))

  default = {}
}

variable "ecs_services" {
  description = "Map of ECS services with networking config and resource references"
  type = map(object({
    name                 = string
    cluster_key          = string
    task_definition_key  = string
    tags                 = optional(map(string), {})
    force_new_deployment = optional(bool, false)
    desired_count        = optional(number, 1)
    network_configuration = optional(list(object({
      assign_public_ip   = optional(bool, false)
      subnet_ids         = list(string)
      security_group_ids = optional(list(string), [])
    })), [])

    load_balancer = optional(list(object({
      container_name   = string
      container_port   = number
      target_group_arn = string
    })), [])
  }))
  default = {}
}
