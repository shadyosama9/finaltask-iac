resource "aws_vpc_endpoint" "this" {
  for_each = var.vpc_endpoints != null ? var.vpc_endpoints : {}

  vpc_id            = aws_vpc.this[each.value.vpc_key].id
  service_name      = each.value.service_name
  vpc_endpoint_type = "Gateway"

  route_table_ids = [for rt_key in each.value.route_table_keys : aws_route_table.this[rt_key].id]

  # Policy document
  policy = each.value.policy_json

  # Timeouts
  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []
    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = merge(
    {
      Name = format("%s-%s-vpc-endpoint", var.env, each.key)
    },
    var.tags
  )

  depends_on = [aws_vpc.this, aws_route_table.this]
}