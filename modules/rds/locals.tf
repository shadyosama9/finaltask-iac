locals {
  rds_subnet_mappings = {
    for key, value in var.subnet_groups :
    key => {
      name        = value.name
      description = lookup(value, "description", "Managed by Terraform")
      subnet_ids  = [for id in value.subnet_keys : var.subnet_ids[id]]
    }
  }

  rds_log_groups = merge([
    for rds_key, rds_val in var.rds : {
      for log_type in rds_val.enabled_cloudwatch_logs_exports :
      "${rds_key}/${log_type}" => {
        name              = "/aws/rds/instance/${rds_val.identifier}/${log_type}"
        retention_in_days = rds_val.cloudwatch_logs_retention_days
      }
    }
    if length(rds_val.enabled_cloudwatch_logs_exports) > 0
  ]...)
}

