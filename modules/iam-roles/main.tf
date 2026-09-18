resource "aws_iam_role" "this" {
  for_each = var.roles

  name        = each.key
  description = each.value.description
  
  assume_role_policy = each.value.federated_provider_arn != "" ? jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = each.value.federated_provider_arn
        }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = each.value.oidc_condition
        }
      }
    ]
  }) : jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = each.value.service
        }
        Action = each.value.service == "pods.eks.amazonaws.com" ? [
          "sts:AssumeRole",
          "sts:TagSession"
        ] : ["sts:AssumeRole"]
      }
    ]
  })

  tags = merge({
    Name = format("%s-%s-%s-role", var.project, var.env, each.key)
  }, var.tags)
}

data "aws_caller_identity" "current" {}


resource "aws_iam_role_policy_attachment" "this" {
  for_each = {
    for item in local.flattened_policy_attachments :
    "${item.role_name}-${replace(item.policy_arn, "[:/.]", "-")}" => item
  }

  role       = aws_iam_role.this[each.value.role_name].name
  policy_arn = each.value.policy_arn
}

resource "aws_iam_role_policy" "this" {
  for_each = {
    for item in local.flattened_inline_policies :
    "${item.role_name}-${item.policy_name}" => item
  }

  name   = each.value.policy_name
  role   = aws_iam_role.this[each.value.role_name].name
  policy = each.value.policy_doc
}

resource "aws_iam_policy" "this" {
  for_each = var.policies

  name        = each.key
  description = each.value.description
  policy      = each.value.policy_document

  tags = merge({
    Name = format("%s-%s-%s-policy", var.project, var.env, each.key)
  }, var.tags)
}

resource "aws_iam_instance_profile" "this" {
  for_each = { for role_name, role in var.roles : role_name => role if role.create_instance_profile }

  name = each.key
  role = aws_iam_role.this[each.key].name

  tags = merge({
    Name = format("%s-%s-%s-instance-profile", var.project, var.env, each.key)
  }, var.tags)
}