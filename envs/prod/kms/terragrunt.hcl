terraform {
  source = "../../../modules/kms"
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

inputs = {
  env     = include.env.locals.env
  project = include.project.locals.project
  tags    = include.tags.locals.tags

  keys = { # optional (map(object), default: {})
    rds = {
      name                    = "rds-key"
      region                  = "us-east-1"
      description             = "KMS key for Postgres RDS instances"
      deletion_window_in_days = 10
      enable_key_rotation     = true
      rotation_period_in_days = 90
    }
  }
}
