terraform {
  source = "../../../modules/ecr"
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

  ecr = {
    backend = {
      name                 = "shady-osama-backend-repo"
      image_tag_mutability = "MUTABLE"
      image_scanning_configuration = {
        scan_on_push = true
      }
    }
  }
}
