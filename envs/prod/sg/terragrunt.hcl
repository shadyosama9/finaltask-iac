terraform {
  source = "../../../modules/security-groups"
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

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_ids = {
      main = "vpc-mock123"
    }
  }
}

inputs = {
  env     = include.env.locals.env
  project = include.project.locals.project
  tags    = include.tags.locals.tags

  vpc_ids = dependency.vpc.outputs.vpc_ids

  security_groups = {
    postgres = {
      # ─── Basic Configuration ──────────────────────────────────────────
      name        = "postgres-rds"                              # required (string)
      vpc_key     = "main"                                      # required (string) - must match a key in the `vpc_ids` map above
      description = "Security group for Postgres RDS instances" # optional (string, default: null)
  
      # ─── Ingress Rules ────────────────────────────────────────────────
      ingress_rules = [ # optional (list(object), default: [])
        {
          name                          = "shady-osama-allow-ecs-access-to-rds" # optional (string, default: null)
          description                   = "Allowing ECS Access To RDS"          # optional (string, default: null)
          from_port                     = 5432                                  # required (number)
          to_port                       = 5432                                  # required (number)
          ip_protocol                   = "tcp"                                 # required (string)
          referenced_security_group_key = "ecs"                                 # ECS security group key
        },
      ]

      # ─── Egress Rules ─────────────────────────────────────────────────
      egress_rules = [{
        name        = "shady-osama-allow-all-outbound"
        ip_protocol = "-1"
        from_port   = null
        to_port     = null
        cidr_ipv4   = "0.0.0.0/0"
        tags        = {}
      }]
      
      tags        = {
        Name = "shady-osama-postgres-rds-sg"
      }
    },

    load_balancer = {
      name        = "load-balancer-sg"
      description = "Security group for load balancer"
      vpc_key     = "main"
      ingress_rules = [
        {
          name        = "shady-osama-allow-http"
          ip_protocol = "tcp"
          from_port   = 80
          to_port     = 80
          cidr_ipv4   = "0.0.0.0/0"
          tags        = {}
        },
        {
          name        = "shady-osama-allow-https"
          ip_protocol = "tcp"
          from_port   = 443
          to_port     = 443
          cidr_ipv4   = "0.0.0.0/0"
          tags        = {}
        }
      ]
      egress_rules = [{
        name        = "shady-osama-allow-all-outbound"
        ip_protocol = "-1"
        from_port   = null
        to_port     = null
        cidr_ipv4   = "0.0.0.0/0"
        tags        = {}
      }]
      tags = {
        Name = "shady-osama-lb-sg"
      }
    },

    ecs = {
      name        = "ecs"
      description = "Security group for ECS"
      vpc_key     = "main"
      ingress_rules = [{
        name                          = "shady-osama-allow-load-balancer"
        ip_protocol                   = "tcp"
        from_port                     = 5000
        to_port                       = 5000
        referenced_security_group_key = "load_balancer"
        tags                          = {}
      }]
      egress_rules = [{
        name        = "shady-osama-allow-all-outbound"
        ip_protocol = "-1"
        from_port   = null
        to_port     = null
        cidr_ipv4   = "0.0.0.0/0"
        tags        = {}
      }]
      tags = {
        Name = "shady-osama-ecs-sg"
      }
    }
  }
}
