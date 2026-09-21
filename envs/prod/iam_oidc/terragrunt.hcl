terraform {
  source = "../../../modules/iam-oidc"
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

dependency "ecr" {
  config_path = "../ecr"
}

dependency "ecs" {
  config_path = "../ecs"
}

dependency "iam-roles" {
  config_path = "../iam-roles"
}


inputs = {
  env     = include.env.locals.env
  project = include.project.locals.project
  tags    = include.tags.locals.tags

  existing_oidc_providers = {
    github = {
      arn = "arn:aws:iam::253650698585:oidc-provider/token.actions.githubusercontent.com"
      url = "https://token.actions.githubusercontent.com"
    }
  }

  roles = { # required (map(object))
    github-deployer = {
      # ─── Basic Configuration ──────────────────────────────────────────
      name        = "deployer"                                   # required (string)
      description = "Assumed by Github Actions to deploy to AWS" # optional (string, default: "")

      # ─── OIDC Trust Configuration ─────────────────────────────────────
      oidc_provider_key = "github"            # required (string)
      audience          = "sts.amazonaws.com" # required (string)
      subjects = [                            # required (list(string))
        "repo:shadyosama9/vue3-realworld-example-app:ref:refs/heads/main",
      ]

      # ─── Inline Policies ──────────────────────────────────────────────
      inline_policies = { # optional (map(string), default: {})
        ecr-push = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "ecr:GetAuthorizationToken"
              ]
              Resource = "*"
            },
            {
              Effect = "Allow"
              Action = [
                "ecr:BatchCheckLayerAvailability",
                "ecr:CompleteLayerUpload",
                "ecr:InitiateLayerUpload",
                "ecr:PutImage",
                "ecr:UploadLayerPart",
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer"
              ]
              Resource = [dependency.ecr.outputs.repository_arns["backend"]]
            }
          ]
        })
        ecs-deploy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "ecs:RegisterTaskDefinition"
              ]
              Resource = ["${dependency.ecs.outputs.task_definition_arns["ecs-task"]}:*"]
            },
            {
              Effect = "Allow"
              Action = [
                "ecs:ListTaskDefinitions",
                "ecs:DescribeTaskDefinition"
              ]
              Resource = "*"
            },
            {
              Effect = "Allow"
              Action = [
                "ecs:UpdateService",
                "ecs:DescribeServices"
              ]
              Resource = [dependency.ecs.outputs.ecs_service_arns["ecs-service"]]
            },
            {
              Effect = "Allow"
              Action = ["iam:PassRole"]
              Resource = [
                dependency.iam-roles.outputs.role_arns["ecs_task_execution_role"],
                dependency.iam-roles.outputs.role_arns["ecs_task_role"]
              ]
              Condition = {
                StringLike = {
                  "iam:PassedToService" = "ecs-tasks.amazonaws.com"
                }
              }
            }
          ]
        })
      }
    }
  }
}
