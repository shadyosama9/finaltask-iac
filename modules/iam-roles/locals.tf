# Flatten the policy attachments
locals {
  flattened_policy_attachments = flatten([
    for role_name, role in var.roles : [
      for policy_arn in role.policy_arns : {
        role_name  = role_name
        policy_arn = policy_arn
      }
    ]
  ])

  assume_role_policies = {
    for role_name, role in var.roles :
    role_name => (role.service != null && role.external_id != null) ? jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect    = "Allow"
        Principal = { Service = role.service }
        Action    = "sts:AssumeRole"
        Condition = { StringEquals = { "sts:ExternalId" = role.external_id } }
      }]
      }) : role.service != null ? jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect    = "Allow"
        Principal = { Service = role.service }
        Action    = "sts:AssumeRole"
      }]
      }) : role.external_id != null ? jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect    = "Allow"
        Principal = { AWS = role.trusted_entity }
        Action    = "sts:AssumeRole"
        Condition = { StringEquals = { "sts:ExternalId" = role.external_id } }
      }]
      }) : jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect    = "Allow"
        Principal = { AWS = role.trusted_entity }
        Action    = "sts:AssumeRole"
      }]
    })
  }
}





locals {
  flattened_inline_policies = flatten([
    for role_name, role in var.roles : [
      for policy_name, policy_doc in lookup(role, "inline_policies", {}) : {
        role_name   = role_name
        policy_name = policy_name
        policy_doc  = policy_doc
      }
    ]
  ])
}



