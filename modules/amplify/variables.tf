variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "amplify_apps" {
  type = map(object({
    # (Required) The name for the Amplify application.
    name = string

    # (Required) The Git repository URL for the Amplify application.
    repository = string

    # (Optional) Environment variables to pass to the Amplify application.
    # These are made available during build time.
    environment_variables = optional(map(string), {})

    # (Optional) The IAM service role ARN for the Amplify application.
    # Required when accessing AWS services like Secrets Manager.
    iam_service_role_arn = optional(string)

    # (Optional) Enables automatic branch creation for the Amplify application.
    # Defaults to true.
    enable_auto_branch_creation = optional(bool, true)

    # (Optional) Enables automatic branch deletion when pull requests are closed.
    # Defaults to true.
    enable_branch_auto_deletion = optional(bool, true)

    # (Optional) OAuth access token for connecting to the repository. Defaults to null.
    access_token = optional(string, null)

    # (Optional) Configuration block for automatic branch creation.
    auto_branch_creation_config = optional(object({
      # (Required) Describes the current stage for the auto-created branch.
      # Valid values: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL_REQUEST.
      stage = string

      # (Optional) The framework used for the auto-created branch.
      framework = optional(string)

      # (Optional) Enables auto building for the auto-created branch.
      # Defaults to true.
      enable_auto_build = optional(bool, true)

      # (Optional) Environment variables specific to auto-created branches.
      environment_variables = optional(map(string), {})

      # (Optional) The basic auth credentials for the auto-created branch.
      basic_auth_credentials = optional(string)

      # (Optional) Enables basic auth for the auto-created branch.
      # Defaults to false.
      enable_basic_auth = optional(bool, false)
    }))

    # (Optional) Custom rewrite and redirect rules for the Amplify application.
    custom_rule = optional(list(object({
      # (Required) The source pattern for the rule.
      source = string

      # (Required) The target pattern for the rule.
      target = string

      # (Required) The HTTP status code for the rule (e.g., 200, 302).
      status = string

      # (Optional) A condition to apply the rule.
      condition = optional(string)
    })), [])


    # (Optional) The ARN of a Secrets Manager secret containing sensitive data.
    secret_arn = optional(string)
  }))
  default = {}
}

variable "amplify_branches" {
  type = map(object({
    # (Required) The key of the corresponding amplify_apps entry.
    name = string

    # (Required) The name of the branch in the repository (e.g., main, develop).
    branch_name = string

    # (Required) The stage of the branch (e.g., staging).
    stage = optional(string, null)

    # (Optional) Environment variables specific to this branch.
    # Defaults to empty map.
    environment_variables = optional(map(string), {})

    # (Optional) Enables build notifications for this branch.
    # Defaults to false.
    enable_notification = optional(bool, false)

    # (Optional) Enables automatic builds for this branch on changes.
    # Defaults to true.
    enable_auto_build = optional(bool, true)

    # (Optional) The framework used by this branch (e.g., React, Vue).
    # Used as a build hint.
    framework = optional(string)
  }))
  default = {}
}

variable "amplify_domains" {
  type = map(object({
    # (Required) The key of the amplify_apps entry this domain is attached to.
    app_name = string

    # (Required) The branch name this domain applies to.
    # branch_name = string

    # (Required) The fully qualified domain name (e.g., app.example.com).
    domain_name = string

    # (Optional) The subdomain prefix (e.g., www).
    # Defaults to empty string.
    subdomains = optional(list(object({
      branch_name      = string
      subdomain_prefix = string
    })), [])


    # (Optional) The certificate type to use.
    # Valid values: AMPLIFY_MANAGED or custom ACM ARN.
    # Defaults to AMPLIFY_MANAGED.
    certificate_type       = optional(string, "AMPLIFY_MANAGED")
    custom_certificate_arn = optional(string, null)

    # (Optional) Whether to wait for domain verification to complete.
    # Defaults to false.
    wait_for_verification = optional(bool, false)
  }))
  default = {}
}


# Specified in terraform.tfvars
variable "github_token" {
  description = "GitHub personal access token for Amplify to connect to repos"
  type        = string
  sensitive   = true
}
