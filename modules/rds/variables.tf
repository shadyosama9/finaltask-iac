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

variable "subnet_ids" {
  description = "Map of subnet names to their corresponding subnet IDs"
  type        = map(string)
}

variable "subnet_groups" {
  description = "Map of RDS subnet group configurations"
  type = map(object({
    # (Required) The name of the subnet group.
    name = string

    # (Optional) A description for the subnet group. Defaults to null.
    description = optional(string)

    # (Required) The subnet keys from the subnet_ids map to include in the group.
    subnet_keys = list(string)
  }))
  default = {}
}

variable "rds" {
  description = "Map of RDS instance configurations"
  type = map(object({
    # (Required) The DB instance identifier.
    identifier = string

    # (Required) The database engine (e.g., postgres, mysql).
    engine = string

    # (Required) The engine version (e.g., 17, 8.0).
    engine_version = string

    # (Required) The instance class (e.g., db.t3.micro).
    instance_class = string

    # (Optional) The name of the database to create. Defaults to null.
    db_name = optional(string, null)

    # (Required) The master username for the database.
    username = string

    # (Optional) Whether to manage the master user password. Defaults to true.
    manage_master_user_password = optional(bool, true)

    # (Optional) The key of the parameter group in var.parameters to use. Defaults to null.
    parameter_group_key_name = optional(string, null)

    # (Required) The allocated storage in GiB.
    allocated_storage = number

    # (Required) Whether to encrypt the storage.
    storage_encrypted = bool

    # (Optional) The ARN of the KMS key for storage encryption. Defaults to null.
    kms_key_id = optional(string, null)

    # (Optional) The storage type (gp2, gp3, io1). Defaults to "gp2".
    storage_type = optional(string, "gp2")

    # (Optional) The upper limit in GiB for autoscaling storage. Defaults to 0 (disabled).
    max_allocated_storage = optional(number, 0)

    # (Optional) Whether to enable IAM database authentication. Defaults to false.
    iam_database_authentication_enabled = optional(bool, false)

    # (Optional) A list of VPC security group IDs to associate. Defaults to null.
    vpc_security_group_ids = optional(list(string))

    # (Optional) The key of the subnet group in var.subnet_groups to use. Defaults to null.
    db_subnet_group_key_name = optional(string, null)

    # (Required) Whether to enable Multi-AZ deployment.
    multi_az = bool

    # (Required) The number of days to retain automated backups.
    backup_retention_period = string

    # (Optional) Whether to skip the final snapshot on deletion. Defaults to false.
    skip_final_snapshot = optional(bool, false)

    # (Required) Whether to enable deletion protection.
    deletion_protection = bool

    # (Optional) Whether to apply changes immediately. Defaults to true.
    apply_immediately = optional(bool, true)

    # (Optional) Whether to automatically upgrade minor engine versions. Defaults to true.
    auto_minor_version_upgrade = optional(bool, true)

    # (Optional) Whether to copy tags to snapshots. Defaults to false.
    copy_tags_to_snapshot = optional(bool, false)

    # (Optional) Log types to export to CloudWatch. Defaults to [].
    enabled_cloudwatch_logs_exports = optional(set(string), [])

    # (Optional) The number of days to retain CloudWatch log exports. Defaults to 7.
    cloudwatch_logs_retention_days = optional(number, 7)

    # (Optional) Whether to enable Performance Insights. Defaults to false.
    performance_insights_enabled = optional(bool, false)

    # (Optional) Whether to allow major version upgrades. Defaults to false.
    allow_major_version_upgrade = optional(bool, false)
  }))

  default = {}
}

variable "rds_replicas" {
  description = "Configuration for RDS read replicas"
  type = map(object({
    # (Required) The DB instance identifier for the replica.
    identifier = string

    # (Required) The instance class for the replica.
    instance_class = string

    # (Required) The identifier of the source DB instance to replicate.
    source_db_instance_identifier = string

    # (Optional) The key of the subnet group in var.subnet_groups to use. Defaults to null.
    db_subnet_group_key_name = optional(string, null)

    # (Optional) The key of the parameter group in var.parameters to use. Defaults to null.
    parameter_group_key_name = optional(string, null)

    # (Optional) VPC security group IDs for the replica. Defaults to null.
    vpc_security_group_ids = optional(list(string))

    # (Optional) Whether to enable Multi-AZ for the replica. Defaults to false.
    multi_az = optional(bool, false)

    # (Optional) Whether the replica is publicly accessible. Defaults to false.
    publicly_accessible = optional(bool, false)

    # (Optional) Whether to auto-upgrade minor engine versions. Defaults to true.
    auto_minor_version_upgrade = optional(bool, true)

    # (Optional) Whether to encrypt the replica storage. Defaults to true.
    storage_encrypted = optional(bool, true)

    # (Optional) The KMS key ARN for replica storage encryption. Defaults to null.
    kms_key_id = optional(string, null)

    # (Optional) Whether to enable deletion protection on the replica. Defaults to false.
    deletion_protection = optional(bool, false)

    # (Optional) Whether to skip the final snapshot on deletion. Defaults to false.
    skip_final_snapshot = optional(bool, false)

    # (Optional) The number of days to retain automated backups. Defaults to "0".
    backup_retention_period = optional(string, "0")

    # (Optional) The upper limit in GiB for autoscaling storage. Defaults to 0.
    max_allocated_storage = optional(number, 0)

    # (Optional) Log types to export to CloudWatch. Defaults to [].
    enabled_cloudwatch_logs_exports = optional(set(string), [])

    # (Optional) Whether to enable Performance Insights. Defaults to false.
    performance_insights_enabled = optional(bool, false)
  }))

  default = {}
}

variable "parameters" {
  description = "Map of DB parameter group configurations"
  type = map(object({
    # (Required) The name of the DB parameter group.
    name = string

    # (Required) The DB parameter group family (e.g., postgres17, mysql8.0).
    family = string

    # (Required) List of parameters to apply to the parameter group.
    parameter = list(object({
      # (Required) The name of the parameter.
      name = string

      # (Required) The value of the parameter.
      value = string
    }))
  }))
  default = {}
}
