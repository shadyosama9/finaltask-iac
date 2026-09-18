terraform {
  source = "../../../modules/secrets_manager"
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
  env        = include.env.locals.env
  project    = include.project.locals.project
  tags       = include.tags.locals.tags

  secrets = {
    backend = {
      name = "shady-osama-backend-secret"
      description = "Secret for backend application"
      secret_string = jsonencode({})
    }
  }
}


