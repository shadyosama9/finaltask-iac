resource "aws_kms_key" "this" {
  for_each = var.keys

  region                  = each.value.region
  description             = each.value.description
  deletion_window_in_days = each.value.deletion_window_in_days
  enable_key_rotation     = each.value.enable_key_rotation
  policy                  = each.value.policy

  tags = merge(
    {
      Name = format("%s-%s-%s-key", var.project, var.env, each.key)
    },
    var.tags
  )
}

resource "aws_kms_alias" "this" {
  for_each = { for k, v in var.keys : k => v if v.alias != null }

  region        = each.value.region
  name          = "alias/${each.value.alias}"
  target_key_id = aws_kms_key.this[each.key].key_id
}
