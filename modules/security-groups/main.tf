resource "aws_security_group" "this" {
  for_each = var.security_groups

  name        = each.value.name
  description = each.value.description
  vpc_id      = var.vpc_ids[each.value.vpc_key]

  tags = merge(
    var.tags,
    each.value.tags
  )
}