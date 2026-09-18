locals {
  env        = "prod"
  project    = "final-task"

  tags = {
    env        = local.env
    project    = "final-task"
    tf-managed = true
  }
}