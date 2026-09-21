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
    name            = string
    description     = optional(string, "")
    service         = optional(string, null)
    trusted_entity  = optional(string, null)
    external_id     = optional(string, null)
    policy_arns     = optional(list(string), [])
    inline_policies = optional(map(string), {})
  }))
}