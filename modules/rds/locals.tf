locals {
  rds_subnet_mappings = {
    for key, value in var.subnet_groups :
    key => {
      name        = value.name
      description = lookup(value, "description", "Managed by Terraform")
      subnet_ids  = [for id in value.subnet_keys : var.subnet_ids[id]]
    }
  }

  rds_cloudwatch_log_groups = {
    for pair in concat(
      flatten([
        for k, v in var.rds : [
          for export in v.enabled_cloudwatch_logs_exports : {
            identifier = v.identifier
            export     = export
          }
        ]
      ]),
      flatten([
        for k, v in var.rds_replicas : [
          for export in v.enabled_cloudwatch_logs_exports : {
            identifier = v.identifier
            export     = export
          }
        ]
      ])
    ) : "${pair.identifier}/${pair.export}" => pair
  }
}

