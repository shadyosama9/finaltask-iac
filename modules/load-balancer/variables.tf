variable "tags" {
  description = "Default tags to apply to all resources"
  type        = map(any)
  default     = {}
}

variable "load_balancers" {
  description = "A map of load balancer configurations"
  type = map(object({
    name                       = string
    internal                   = bool
    load_balancer_type         = string
    security_groups            = list(string)
    subnets                    = list(string)
    enable_deletion_protection = bool
    tags                       = map(any)
  }))
}

variable "target_groups" {
  description = "A map of target group configurations"
  type = map(object({
    name        = string
    port        = number
    protocol    = string
    target_type = string
    vpc_id      = string
    health_check = object({
      path                = string
      protocol            = string
      matcher             = string
      interval            = number
      timeout             = number
      healthy_threshold   = number
      unhealthy_threshold = number
    })
  }))
}

variable "listeners" {
  description = "A map of listener configurations"
  type = map(object({
    load_balancer_key = string
    port              = number
    protocol          = string
    ssl_policy        = optional(string)
    certificate_arn   = optional(string)
    default_action = optional(object({
      type             = string
      target_group_arn = optional(string)
      order            = optional(number)
      fixed_response = optional(object({
        content_type = string
        message_body = optional(string)
        status_code  = string
      }))
      redirect = optional(object({
        protocol    = optional(string)
        port        = optional(string)
        host        = optional(string)
        path        = optional(string)
        query       = optional(string)
        status_code = optional(string)
      }))
    }))
    tags = map(any)
  }))
}

variable "listener_rules" {
  description = "A map of listener rules"
  type = map(object({
    listener_key     = string
    priority         = number
    target_group_key = string
    host_headers     = list(string)
    tags = optional(map(any))
  }))
  default = {}
}