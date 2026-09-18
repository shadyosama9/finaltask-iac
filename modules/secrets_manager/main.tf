resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name                    = each.value.name
  description             = each.value.description
  recovery_window_in_days = each.value.recovery_window_in_days

  tags = merge(
    {
      Name = format("%s-%s-secret", var.project, var.env)
    },
    var.tags
  )
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = aws_secretsmanager_secret.this

  secret_id     = each.value.id
  secret_string = var.secrets[each.key].secret_string
  lifecycle {
    ignore_changes = all
  }
}

# resource "aws_vpc_endpoint" "this" {
#   for_each = var.vpc_endpoints

#   vpc_id              = each.value.vpc_id
#   service_name        = "com.amazonaws.us-east-1.secretsmanager"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = each.value.subnet_ids
#   security_group_ids  = each.value.security_group_ids
#   private_dns_enabled = each.value.public_dns_enabled

#   tags = merge(
#     {
#       Name = format("%s-%s-secretsmanager-endpoint", var.project, var.env)
#     },
#     var.tags
#   )
# }
