terraform {
  source = "../../../modules/iam-roles"
}

include "root" {
  path = "${get_parent_terragrunt_dir()}/../root.hcl"
}
include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {
  env     = include.env.locals.env
  project = include.env.locals.project
  tags    = include.env.locals.tags

  roles = {
    ecs_task_execution_role = {
      description = "IAM role assumed by ECS to launch and manage containers on your behalf"
      service     = "ecs-tasks.amazonaws.com"
      policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
      ]
    }
    ecs_task_role = {
      description = "IAM role assumed by the application running inside the container"
      service     = "ecs-tasks.amazonaws.com"
      policy_arns = [
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]
    }
  }
}

