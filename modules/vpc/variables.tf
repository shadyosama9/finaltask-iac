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

variable "vpc" {
  type = map(object({
    create_igw           = bool
    cidr_block           = string
    enable_dns_hostnames = bool
    enable_dns_support   = bool
  }))

  default = {}
}

variable "eip" {
  type = map(object({
    create            = bool
    domain            = optional(string, "vpc")
    instance          = optional(string, null) # Optional instance association
    network_interface = optional(string, null) # Optional network interface association
  }))

  default = {}
}

variable "nat" {
  type = map(object({
    eip_key    = string
    subnet_key = string
  }))

  default = {}
}

variable "subnets" {
  type = map(object({
    vpc_key                 = string
    create_nacl             = bool
    availability_zone       = string
    cidr_block              = string
    map_public_ip_on_launch = bool
    rules                   = optional(list(map(any)))
    tags                    = optional(map(any), {})
  }))

  default = {}
}


variable "enable_managed_prefix" {
  type    = bool
  default = false
}

variable "route_tables" {
  type = map(object({
    vpc_key     = string
    subnet_keys = list(string) # Must match the actual subnet key name defined in var.subnets
    use_igw     = optional(bool, false)
    use_nat     = optional(bool, false)
    use_prefix  = optional(bool, false)
    nat_key     = optional(string, null) # Key for NAT gateway if use_nat is true
    routes      = list(map(any))
  }))
  default = {}
}


variable "flow_logs" {
  description = "Map of VPC flow log configurations (CloudWatch Logs destination)"
  type = map(object({
    vpc_key        = string
    traffic_type   = optional(string, "ALL")
    retention_days = optional(number, 30)
  }))
  default = {}
}

variable "vpc_endpoints" {
  description = "Map of Gateway VPC endpoints to create (set to null or {} to skip creation)"
  type = map(object({
    vpc_key          = string
    service_name     = string
    route_table_keys = list(string)

    # Policy
    policy_json = optional(string, null)

    # Timeouts
    timeouts = optional(object({
      create = optional(string, "60m")
      update = optional(string, "60m")
      delete = optional(string, "60m")
    }))

    # Additional tags
    tags = optional(map(string), {})
  }))
  default = null
}