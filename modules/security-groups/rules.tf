resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = local.ingress_rules_flattened

  security_group_id            = aws_security_group.this[each.value.sg_name].id
  description                  = each.value.rule.name
  ip_protocol                  = each.value.rule.ip_protocol
  from_port                    = each.value.rule.from_port
  to_port                      = each.value.rule.to_port
  cidr_ipv4                    = each.value.rule.cidr_ipv4
  referenced_security_group_id = each.value.rule.referenced_security_group_key != null ? aws_security_group.this[each.value.rule.referenced_security_group_key].id : each.value.rule.referenced_security_group_id

  tags = merge(
    var.tags,
    each.value.rule.tags
  )
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = local.egress_rules_flattened

  security_group_id            = aws_security_group.this[each.value.sg_name].id
  description                  = each.value.rule.name
  ip_protocol                  = each.value.rule.ip_protocol
  from_port                    = each.value.rule.from_port
  to_port                      = each.value.rule.to_port
  cidr_ipv4                    = each.value.rule.cidr_ipv4
  referenced_security_group_id = each.value.rule.referenced_security_group_key != null ? aws_security_group.this[each.value.rule.referenced_security_group_key].id : each.value.rule.referenced_security_group_id

  tags = merge(
    var.tags,
    each.value.rule.tags
  )
}
