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

variable "dashboards" {
  description = "A map of CloudWatch dashboards to create. The key is an identifier and the value is an object with dashboard_name and dashboard_body."
  type = map(object({
    # (Required) The name of the CloudWatch dashboard.
    dashboard_name = string
    # (Required) The JSON body of the dashboard.
    dashboard_body = string
  }))
  default = {}
}
