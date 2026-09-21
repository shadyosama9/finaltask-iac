resource "aws_cloudwatch_log_group" "rds" {
  for_each = local.rds_log_groups

  name              = each.value.name
  retention_in_days = each.value.retention_in_days

  tags = var.tags
}

resource "aws_db_instance" "main" {
  for_each = var.rds

  # ─── Core Configuration ──────────────────────────────────────────
  identifier           = each.value.identifier
  engine               = each.value.engine
  engine_version       = each.value.engine_version
  db_name              = each.value.db_name
  instance_class       = each.value.instance_class
  parameter_group_name = aws_db_parameter_group.this[each.value.parameter_group_key_name].name

  # ─── Storage ─────────────────────────────────────────────────────
  allocated_storage     = each.value.allocated_storage
  storage_type          = each.value.storage_type
  storage_encrypted     = each.value.storage_encrypted
  kms_key_id            = each.value.kms_key_id
  max_allocated_storage = each.value.max_allocated_storage

  # ─── Authentication ───────────────────────────────────────────────
  username                            = each.value.username
  manage_master_user_password          = each.value.manage_master_user_password
  # password                            = random_password.this[each.key].result
  iam_database_authentication_enabled = each.value.iam_database_authentication_enabled

  # ─── Networking ───────────────────────────────────────────────────
  db_subnet_group_name   = aws_db_subnet_group.this[each.value.db_subnet_group_key_name].name
  vpc_security_group_ids = each.value.vpc_security_group_ids

  # ─── High Availability ────────────────────────────────────────────
  multi_az = each.value.multi_az

  # ─── Backup & Snapshots ───────────────────────────────────────────
  backup_retention_period = each.value.backup_retention_period
  skip_final_snapshot     = each.value.skip_final_snapshot

  # ─── Security ────────────────────────────────────────────────────
  deletion_protection = each.value.deletion_protection

  # ─── Maintenance ─────────────────────────────────────────────────
  apply_immediately               = each.value.apply_immediately
  auto_minor_version_upgrade      = each.value.auto_minor_version_upgrade
  allow_major_version_upgrade     = each.value.allow_major_version_upgrade
  copy_tags_to_snapshot           = each.value.copy_tags_to_snapshot
  enabled_cloudwatch_logs_exports = each.value.enabled_cloudwatch_logs_exports
  performance_insights_enabled    = each.value.performance_insights_enabled

  # ─── Resource Metadata ────────────────────────────────────────────
  tags = var.tags

  depends_on = [aws_db_subnet_group.this, aws_db_parameter_group.this]
  # lifecycle {
  #   ignore_changes = [password]
  # }
}

resource "aws_db_instance" "replica" {
  for_each = var.rds_replicas

  # ─── Core Configuration ──────────────────────────────────────────
  identifier           = each.value.identifier
  instance_class       = each.value.instance_class
  replicate_source_db  = aws_db_instance.main[each.value.source_db_instance_identifier].arn
  parameter_group_name = aws_db_parameter_group.this[each.value.parameter_group_key_name].name

  # ─── Storage ─────────────────────────────────────────────────────
  storage_encrypted     = each.value.storage_encrypted
  kms_key_id            = each.value.kms_key_id
  max_allocated_storage = each.value.max_allocated_storage

  # ─── Networking ───────────────────────────────────────────────────
  db_subnet_group_name   = aws_db_subnet_group.this[each.value.db_subnet_group_key_name].name
  vpc_security_group_ids = each.value.vpc_security_group_ids
  publicly_accessible    = each.value.publicly_accessible

  # ─── High Availability ────────────────────────────────────────────
  multi_az = each.value.multi_az

  # ─── Backup & Snapshots ───────────────────────────────────────────
  backup_retention_period         = each.value.backup_retention_period
  skip_final_snapshot             = each.value.skip_final_snapshot
  enabled_cloudwatch_logs_exports = each.value.enabled_cloudwatch_logs_exports

  # ─── Security ────────────────────────────────────────────────────
  deletion_protection = each.value.deletion_protection

  # ─── Maintenance ─────────────────────────────────────────────────
  auto_minor_version_upgrade = each.value.auto_minor_version_upgrade

  performance_insights_enabled = each.value.performance_insights_enabled

  # ─── Resource Metadata ────────────────────────────────────────────
  tags = var.tags

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

  name   = each.value.name
  family = each.value.family

  dynamic "parameter" {
    for_each = each.value.parameter
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}

# resource "random_password" "this" {
#   for_each = var.rds

#   length  = 19
#   lower   = true
#   numeric = true
#   special = true
#   upper   = true
#   # RDS rejects '/', '@', '"', ' ' in MasterUserPassword
#   override_special = "!#$%^&*()-_=+[]{}|;:,.<>?~`"
# }