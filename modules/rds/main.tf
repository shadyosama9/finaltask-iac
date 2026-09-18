resource "aws_cloudwatch_log_group" "this" {
  for_each = local.rds_cloudwatch_log_groups

  name              = "/aws/rds/instance/${each.value.identifier}/${each.value.export}"
  retention_in_days = var.log_groups[each.key].retention_in_days
  tags              = var.tags
}

resource "aws_db_instance" "this" {
  for_each = var.rds

  # Core database configuration
  identifier           = each.value.identifier
  engine               = each.value.engine
  engine_version       = each.value.engine_version
  db_name              = each.value.db_name
  instance_class       = each.value.instance_class
  parameter_group_name = each.value.parameter_group_name

  # Storage
  allocated_storage     = each.value.allocated_storage
  storage_type          = each.value.storage_type
  storage_encrypted     = each.value.storage_encrypted
  kms_key_id            = each.value.kms_key_id
  max_allocated_storage = each.value.max_allocated_storage

  # Authentication
  username                            = each.value.username
  password                            = random_password.this[each.key].result
  iam_database_authentication_enabled = each.value.iam_database_authentication_enabled

  # Networking
  db_subnet_group_name   = each.value.db_subnet_group_name
  vpc_security_group_ids = each.value.vpc_security_group_ids

  # High availability
  multi_az = each.value.multi_az

  # Backup/snapshots
  backup_retention_period = each.value.backup_retention_period
  skip_final_snapshot     = each.value.skip_final_snapshot

  # Security
  deletion_protection = each.value.deletion_protection

  # Maintenance
  apply_immediately               = each.value.apply_immediately
  auto_minor_version_upgrade      = each.value.auto_minor_version_upgrade
  allow_major_version_upgrade     = each.value.allow_major_version_upgrade
  copy_tags_to_snapshot           = each.value.copy_tags_to_snapshot
  enabled_cloudwatch_logs_exports = each.value.enabled_cloudwatch_logs_exports
  performance_insights_enabled    = each.value.performance_insights_enabled
  # Tags
  tags = var.tags

  depends_on = [aws_db_subnet_group.this, aws_db_parameter_group.this]
  lifecycle {
    ignore_changes = [password]
  }
}

resource "aws_db_instance" "replica" {
  for_each = var.rds_replicas

  # Core database configuration
  identifier           = each.value.identifier
  instance_class       = each.value.instance_class
  replicate_source_db  = aws_db_instance.this[each.value.source_db_instance_identifier].arn
  engine_version       = each.value.engine_version
  parameter_group_name = each.value.parameter_group_name

  # Storage encryption
  storage_encrypted     = each.value.storage_encrypted
  kms_key_id            = each.value.kms_key_id
  max_allocated_storage = each.value.max_allocated_storage

  # Networking
  db_subnet_group_name   = each.value.db_subnet_group_name
  vpc_security_group_ids = each.value.vpc_security_group_ids
  publicly_accessible    = each.value.publicly_accessible

  # High availability
  multi_az = each.value.multi_az

  # Backup/snapshots
  backup_retention_period         = each.value.backup_retention_period
  skip_final_snapshot             = each.value.skip_final_snapshot
  enabled_cloudwatch_logs_exports = each.value.enabled_cloudwatch_logs_exports

  # Security
  deletion_protection = each.value.deletion_protection

  # Maintenance
  auto_minor_version_upgrade  = each.value.auto_minor_version_upgrade
  allow_major_version_upgrade = each.value.allow_major_version_upgrade
  copy_tags_to_snapshot       = each.value.copy_tags_to_snapshot
  apply_immediately           = each.value.apply_immediately

  performance_insights_enabled = each.value.performance_insights_enabled

  # Tags
  tags = var.tags

  depends_on = [aws_db_parameter_group.this]

  lifecycle {
    ignore_changes = [kms_key_id]
  }
}

resource "aws_db_subnet_group" "this" {

  for_each = local.rds_subnet_mappings

  name        = each.value.name
  description = each.value.description
  subnet_ids  = each.value.subnet_ids

  tags = merge(
    {
      Name = format("%s-%s-%s-subnet-group", var.project, var.env, each.key)
    },
    var.tags
  )
}

resource "aws_db_parameter_group" "this" {

  for_each = var.parameters

  name        = each.value.name
  family      = each.value.family
  description = each.value.description

  dynamic "parameter" {
    for_each = each.value.parameter
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}

resource "random_password" "this" {
  for_each = var.rds

  length  = 19
  lower   = true
  numeric = true
  special = true
  upper   = true
  # override_special = "!@#$%^&*()-_=+[]{}|;:,.<>?/~`"
}