variable "env" {
  type = string
}

variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "tags" {
  type = map(any)
}

variable "keys" {
  description = "Map of KMS keys to create, keyed by logical name"
  type = map(object({
    description             = string
    policy                  = string
    region                  = optional(string, "us-east-1")
    deletion_window_in_days = optional(number, 30)
    enable_key_rotation     = optional(bool, true)
    alias                   = optional(string)
  }))
}
