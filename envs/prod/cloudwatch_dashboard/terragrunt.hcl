terraform {
  source = "../../../modules/cloudwatch_dashboard"
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

dependency "rds" {
  config_path = "../rds"
}

dependency "ecs" {
  config_path = "../ecs"
}

dependency "load_balancer" {
  config_path = "../load-balancer"
}

inputs = {
  project = include.project.locals.project
  env     = include.env.locals.env
  tags    = include.tags.locals.tags

  dashboards = {
    rds = {
      dashboard_name = "shady-osama-${include.project.locals.project}-${include.env.locals.env}-rds"

      dashboard_body = jsonencode({
        widgets = [
          {
            type   = "metric"
            x      = 0
            y      = 0
            width  = 12
            height = 6

            properties = {
              title  = "RDS CPU Utilization"
              region = "us-east-1"
              view   = "timeSeries"
              stat   = "Average"
              period = 300

              metrics = [
                [
                  "AWS/RDS",
                  "CPUUtilization",
                  "DBInstanceIdentifier",
                  dependency.rds.outputs.db_identifiers["postgres"]
                ]
              ]
            }
          },
          {
            type   = "metric"
            x      = 12
            y      = 0
            width  = 12
            height = 6

            properties = {
              title  = "RDS Database Connections"
              region = "us-east-1"
              view   = "timeSeries"
              stat   = "Average"
              period = 300

              metrics = [
                [
                  "AWS/RDS",
                  "DatabaseConnections",
                  "DBInstanceIdentifier",
                  dependency.rds.outputs.db_identifiers["postgres"]
                ]
              ]
            }
          },
          {
            type   = "metric"
            x      = 0
            y      = 6
            width  = 12
            height = 6

            properties = {
              title  = "RDS Free Storage"
              region = "us-east-1"
              view   = "timeSeries"
              stat   = "Average"
              period = 300

              metrics = [
                [
                  "AWS/RDS",
                  "FreeStorageSpace",
                  "DBInstanceIdentifier",
                  dependency.rds.outputs.db_identifiers["postgres"]
                ]
              ]
            }
          },
          {
            type   = "metric"
            x      = 12
            y      = 6
            width  = 12
            height = 6

            properties = {
              title  = "RDS Freeable Memory"
              region = "us-east-1"
              view   = "timeSeries"
              stat   = "Average"
              period = 300

              metrics = [
                [
                  "AWS/RDS",
                  "FreeableMemory",
                  "DBInstanceIdentifier",
                  dependency.rds.outputs.db_identifiers["postgres"]
                ]
              ]
            }
          }
        ]
      })
    }

    ecs = {
      dashboard_name = "shady-osama-${include.project.locals.project}-${include.env.locals.env}-ecs"

      dashboard_body = jsonencode({
        widgets = [
          {
            type   = "metric"
            x      = 0
            y      = 0
            width  = 12
            height = 6

            properties = {
              title  = "ECS CPU Utilization"
              region = "us-east-1"
              view   = "timeSeries"
              stat   = "Average"
              period = 300

              metrics = [
                [
                  "AWS/ECS",
                  "CPUUtilization",
                  "ClusterName",
                  dependency.ecs.outputs.ecs_cluster_names["ecs-service"],
                  "ServiceName",
                  dependency.ecs.outputs.ecs_service_names["ecs-service"]
                ]
              ]
            }
          },
          {
            type   = "metric"
            x      = 12
            y      = 0
            width  = 12
            height = 6

            properties = {
              title  = "ECS Memory Utilization"
              region = "us-east-1"
              view   = "timeSeries"
              stat   = "Average"
              period = 300

              metrics = [
                [
                  "AWS/ECS",
                  "MemoryUtilization",
                  "ClusterName",
                  dependency.ecs.outputs.ecs_cluster_names["ecs-service"],
                  "ServiceName",
                  dependency.ecs.outputs.ecs_service_names["ecs-service"]
                ]
              ]
            }
          }
        ]
      })
    }

    load-balancer = {
      dashboard_name = "shady-osama-${include.project.locals.project}-${include.env.locals.env}-load-balancer"

      dashboard_body = jsonencode({
        widgets = [
          {
            type   = "metric"
            x      = 0
            y      = 0
            width  = 12
            height = 6

            properties = {
              title  = "ALB Request Count"
              region = "us-east-1"
              view   = "timeSeries"
              stat   = "Sum"
              period = 300

              metrics = [
                [
                  "AWS/ApplicationELB",
                  "RequestCount",
                  "LoadBalancer",
                  dependency.load_balancer.outputs.load_balancer_arn_suffixes["alb"]
                ]
              ]
            }
          },
          {
            type   = "metric"
            x      = 12
            y      = 0
            width  = 12
            height = 6

            properties = {
              title  = "ALB ELB 5XX Errors"
              region = "us-east-1"
              view   = "timeSeries"
              stat   = "Sum"
              period = 300

              metrics = [
                [
                  "AWS/ApplicationELB",
                  "HTTPCode_ELB_5XX_Count",
                  "LoadBalancer",
                  dependency.load_balancer.outputs.load_balancer_arn_suffixes["alb"]
                ]
              ]
            }
          },
          {
            type   = "metric"
            x      = 0
            y      = 6
            width  = 12
            height = 6

            properties = {
              title  = "ALB Target 5XX Errors"
              region = "us-east-1"
              view   = "timeSeries"
              stat   = "Sum"
              period = 300

              metrics = [
                [
                  "AWS/ApplicationELB",
                  "HTTPCode_Target_5XX_Count",
                  "LoadBalancer",
                  dependency.load_balancer.outputs.load_balancer_arn_suffixes["alb"]
                ]
              ]
            }
          },
          {
            type   = "metric"
            x      = 12
            y      = 6
            width  = 12
            height = 6

            properties = {
              title  = "ALB Active Connections"
              region = "us-east-1"
              view   = "timeSeries"
              stat   = "Average"
              period = 300

              metrics = [
                [
                  "AWS/ApplicationELB",
                  "ActiveConnectionCount",
                  "LoadBalancer",
                  dependency.load_balancer.outputs.load_balancer_arn_suffixes["alb"]
                ]
              ]
            }
          }
        ]
      })
    }
  }
}