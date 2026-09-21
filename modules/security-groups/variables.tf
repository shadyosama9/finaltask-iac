variable "tags" {
  description = "Default tags to apply to all resources"
  type        = map(any)
  default     = {}
}

variable "vpc_ids" {
  description = "Map of VPC IDs (from any source)"
  type        = map(string)
}

variable "security_groups" {
  description = "A map of security group configurations"
  type = map(object({
    name        = string
    description = string
    vpc_key     = string
    tags = optional(map(any), {})

    ingress_rules = optional(list(object({
      name                          = string
      ip_protocol                   = string
      from_port                     = optional(number)
      to_port                       = optional(number)
      cidr_ipv4                     = optional(string)
      referenced_security_group_id  = optional(string)
      referenced_security_group_key = optional(string)
      tags                          = optional(map(any), {})
    })), [])
    
    egress_rules = optional(list(object({
      name                          = string
      ip_protocol                   = string
      from_port                     = optional(number)
      to_port                       = optional(number)
      cidr_ipv4                     = optional(string)
      referenced_security_group_id  = optional(string)
      referenced_security_group_key = optional(string)
      tags                          = optional(map(any), {})
    })), [])
  }))
}
