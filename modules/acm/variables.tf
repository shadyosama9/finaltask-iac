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

variable "acm" {
  type = map(object({
    domain_name       = string
    validation_method = string
  }))
  default = {}
}
