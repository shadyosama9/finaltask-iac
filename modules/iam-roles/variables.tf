variable "tags" {
  type = map(any)
}

variable "env" {
  type = string
}

variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "roles" {
  description = "Map of roles to create"
  type = map(object({
    description             = optional(string, "")
    service                 = optional(string, "")
    federated_provider_arn  = optional(string, "")
    oidc_condition          = optional(map(string), {})
    policy_arns             = list(string)
    inline_policies         = optional(map(string), {})
    create_instance_profile = optional(bool, false)
  }))
}

variable "policies" {
  description = "Map of customer-managed IAM policies to create"
  type = map(object({
    description     = optional(string, "")
    policy_document = string
  }))
  default = {}
}