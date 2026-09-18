remote_state {
  backend = "s3"
  generate = {
    path      = "state.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    profile = "skillup"
    bucket  = "final-task-state-files"

    key          = "${get_path_from_repo_root()}/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
        provider "aws" {
            region = "us-east-1"
            profile = "skillup"
        }
        provider "aws" {
            region = "us-west-2"
            profile = "skillup"
            alias = "us_west_2"
        }
    EOF
}
