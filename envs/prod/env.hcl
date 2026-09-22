locals {
  env        = "prod"
  project    = "final-task"

  tags = {
    env        = local.env
    project    = local.env
    tf-managed = true
  }
}