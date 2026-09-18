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

variable "secrets" {
  description = "Values of secrets to be stored in the Secrets Manager"
  type = map(object({
    name                    = string
    description             = optional(string)
    secret_string           = optional(string)
    recovery_window_in_days = optional(number, 7)
  }))
  default = {}
}

# variable "vpc_endpoints" {
#   description = "Map of VPC endpoint configs for Secrets Manager"
#   type = map(object({
#     vpc_id             = string
#     subnet_ids         = list(string)
#     security_group_ids = list(string)
#     public_dns_enabled = bool
#   }))
#   default = {}
# }
