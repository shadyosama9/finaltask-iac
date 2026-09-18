resource "aws_lb_listener_rule" "this" {
  for_each = var.listener_rules

  listener_arn = aws_lb_listener.this[each.value.listener_key].arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.target_group_key].arn
  }

  condition {
    host_header {
      values = each.value.host_headers
    }
  }

  tags = merge(
    var.tags,
    each.value.tags
  )
}