locals {
  env        = "prod"
  project    = "final-task"

  tags = {
    env        = local.env
    project    = local.project
    tf-managed = true
  }
}