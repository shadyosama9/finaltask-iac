terraform {
  source = "../../../modules/acm"
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
  project = include.env.locals.project
  tags    = include.env.locals.tags

  acm = {
    cert = {
      domain_name               = "*.shadyosama.vertexlab.net"
      validation_method         = "DNS"
      subject_alternative_names = ["shadyosama.vertexlab.net"]
    }
  }
}
