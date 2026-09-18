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

variable "log_groups" {
  description = "Map of CloudWatch log group configs, keyed by \"<identifier>/<export>\" (same keys as local.rds_cloudwatch_log_groups)"
  type = map(object({
    retention_in_days = optional(number, 14)
  }))
}

variable "subnet_ids" {
  description = "Map of subnet names to their corresponding subnet IDs"
  type        = map(string)
}


variable "subnet_groups" {
  type = map(object({
    name        = string
    description = optional(string)
    subnet_keys = list(string)
  }))
}

variable "rds" {
  type = map(object({
    # Core database configuration
    identifier           = string
    engine               = string
    engine_version       = string
    instance_class       = string
    db_name              = optional(string, null)
    username             = string
    parameter_group_name = optional(string, null)

    # Storage configuration
    allocated_storage     = number
    storage_encrypted     = bool
    kms_key_id            = optional(string, null)
    storage_type          = optional(string, "gp2")
    max_allocated_storage = optional(number, 0)

    #authentication
    iam_database_authentication_enabled = optional(bool, false)

    # Networking
    vpc_security_group_ids = optional(list(string))
    db_subnet_group_name   = optional(string)

    # High availability
    multi_az = bool

    # Backup/maintenance
    backup_retention_period = string
    skip_final_snapshot     = optional(bool, false)

    # Security
    deletion_protection = bool

    # Maintenance
    apply_immediately               = optional(bool, true)
    auto_minor_version_upgrade      = optional(bool, true)
    allow_major_version_upgrade     = optional(bool, false)
    copy_tags_to_snapshot           = optional(bool, false)
    enabled_cloudwatch_logs_exports = optional(set(string), [])
    performance_insights_enabled    = optional(bool, false)
  }))

  default = {}
}

variable "rds_replicas" {
  description = "Configuration for RDS read replicas"
  type = map(object({
    # Replica configuration
    apply_immediately             = optional(bool, true)
    identifier                    = string
    instance_class                = string
    source_db_instance_identifier = string
    engine_version                = optional(string, null)

    # Optional configuration
    db_subnet_group_name            = optional(string)
    parameter_group_name            = optional(string, null)
    vpc_security_group_ids          = optional(list(string))
    multi_az                        = optional(bool, false)
    publicly_accessible             = optional(bool, false)
    auto_minor_version_upgrade      = optional(bool, true)
    allow_major_version_upgrade     = optional(bool, false)
    copy_tags_to_snapshot           = optional(bool, false)
    storage_encrypted               = optional(bool, true)
    kms_key_id                      = optional(string, null)
    deletion_protection             = optional(bool, false)
    skip_final_snapshot             = optional(bool, false)
    backup_retention_period         = optional(string, "0")
    max_allocated_storage           = optional(number, 0)
    enabled_cloudwatch_logs_exports = optional(set(string), [])
    performance_insights_enabled    = optional(bool, false)
  }))

  default = {}
}

variable "parameters" {
  type = map(object({
    name        = string
    family      = string
    description = optional(string, "Managed by Terraform")

    parameter = list(object({
      name  = string
      value = string
    }))
  }))

  default = {}
}