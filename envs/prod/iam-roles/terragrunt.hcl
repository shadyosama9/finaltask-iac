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

include "project" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

include "tags" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

dependency "secrets_manager" {
  config_path = "../secrets_manager"
}

dependency "rds" {
  config_path = "../rds"
}

inputs = {
  env     = include.env.locals.env
  project = include.project.locals.project
  tags    = include.tags.locals.tags

  roles = { # required (map(object))
    ecs_task_execution_role = {
      # ─── Basic Configuration ──────────────────────────────────────────
      name        = "ecs-task-execution-role"                                                # required (string)
      description = "IAM role assumed by ECS to launch and manage containers on your behalf" # optional (string, default: "")
      service     = "ecs-tasks.amazonaws.com"                                                # required (string)

      # ─── Inline Policies ──────────────────────────────────────────────
      policy_arns = [ # optional (list(string), default: [])
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
      ]
      inline_policies = { # optional (map(string), default: {})
        secrets_access = jsonencode({
          Version = "2012-10-17",
          Statement = [
            {
              Effect = "Allow",
              Action = [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
              ],
              Resource = [
                dependency.secrets_manager.outputs.secret_arn["backend"],
                "${dependency.secrets_manager.outputs.secret_arn["backend"]}-*",
                dependency.rds.outputs.rds_master_secret_arns["postgres"],
                "${dependency.rds.outputs.rds_master_secret_arns["postgres"]}-*"
              ]
            },
            {
              Effect   = "Allow",
              Action   = ["kms:Decrypt"],
              Resource = "*",
              Condition = {
                StringEquals = {
                  "kms:ViaService" = "secretsmanager.us-east-1.amazonaws.com"
                }
              }
            }
          ]
        })
      }
    },

    ecs_task_role = {
      # ─── Basic Configuration ──────────────────────────────────────────
      name        = "ecs-task-role"                                                    # required (string)
      description = "IAM role assumed by the application running inside the container" # optional (string, default: "")
      service     = "ecs-tasks.amazonaws.com"                                          # required (string)

      # ─── Inline Policies ──────────────────────────────────────────────
      policy_arns = [ # optional (list(string), default: [])
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
      ]
      # inline_policies = { # optional (map(string), default: {})
      #   app_permissions = jsonencode({
      #     Version = "2012-10-17",
      #     Statement = [
      #       {
      #
      #       },
      #     ]
      #   })
      # }
    }
  }
}
