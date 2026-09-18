terraform {
  source = "../../../modules/ecs"
}

include "root" {
  path = "${get_parent_terragrunt_dir()}/../root.hcl"
}
include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    private_subnet_ids = {
      priv_sub_1 = "subnet-mock1"
      priv_sub_2 = "subnet-mock2"
    }
  }
}
dependency "ecr" {
  config_path = "../ecr"
  mock_outputs = {
    repository_urls = {
      backend = "123456789012.dkr.ecr.us-east-1.amazonaws.com/mock-repo"
    }
  }
}
dependency "iam" {
  config_path = "../iam-roles"
  mock_outputs = {
    role_arns = {
      ecs_task_execution_role = "arn:aws:iam::123456789012:role/mock-execution-role"
      ecs_task_role           = "arn:aws:iam::123456789012:role/mock-task-role"
    }
  }
}
dependency "sg" {
  config_path = "../sg"
  mock_outputs = {
    security_group_ids = {
      ecs = "sg-mockecs"
    }
  }
}
dependency "load_balancer" {
  config_path = "../load-balancer"
  mock_outputs = {
    target_group_arns = {
      tg = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mock-tg/123"
    }
  }
}

inputs = {
  tags = include.env.locals.tags

  cloudwatch_group = {
    ecs-task-logs = {
      name              = "shady-osama-ecs-task-logs"
      retention_in_days = 7
    }
  }

  ecs = {
    ecs-cluster = {
      name = "shady-osama-ecs-cluster"
    }
  }

  task_definition = {
    ecs-task = {
      family                   = "shady-osama-ecs-task"
      execution_role_arn       = dependency.iam.outputs.role_arns["ecs_task_execution_role"]
      task_role_arn            = dependency.iam.outputs.role_arns["ecs_task_role"]
      requires_compatibilities = ["FARGATE"]
      network_mode             = "awsvpc"
      cpu                      = 256
      memory                   = 512
      container_definitions = [{
        name      = "backend"
        image     = "${dependency.ecr.outputs.repository_urls["backend"]}:latest"
        cpu       = 256
        memory    = 512
        essential = true
        port_mappings = [{
          container_port = 5000
          host_port      = 5000
        }]
        log_configuration = {
          log_driver = "awslogs"
          options = {
            awslogs_group         = "ecs-task-logs"
            awslogs_region        = "us-east-1"
            awslogs_stream_prefix = "backend"
          }
        }
      }]
    }
  }

  ecs_services = {
    ecs-service = {
      name                 = "shady-osama-ecs-service"
      cluster_key          = "ecs-cluster"
      task_definition_key  = "ecs-task"
      desired_count        = 1
      force_new_deployment = true
      network_configuration = [{
        assign_public_ip = false
        subnet_ids = [
          dependency.vpc.outputs.private_subnet_ids["priv_sub_1"],
          dependency.vpc.outputs.private_subnet_ids["priv_sub_2"]
        ]
        security_group_ids = [dependency.sg.outputs.security_group_ids["ecs"]]
      }]
      load_balancer = [{
        container_name   = "backend"
        container_port   = 5000
        target_group_arn = dependency.load_balancer.outputs.target_group_arns["tg"]
      }]
    }
  }
}
