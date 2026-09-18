resource "aws_lb_listener" "this" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.this[each.value.load_balancer_key].arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = each.value.ssl_policy != null ? each.value.ssl_policy : null
  certificate_arn   = each.value.certificate_arn != null ? each.value.certificate_arn : null

  dynamic "default_action" {
    for_each = each.value.default_action != null && each.value.default_action.type == "forward" ? [each.value.default_action] : []

    content {
      type             = default_action.value.type
      target_group_arn = aws_lb_target_group.this[default_action.value.target_group_arn].arn
      order            = default_action.value.order != null ? default_action.value.order : null
    }
  }

  dynamic "default_action" {
    for_each = each.value.default_action != null && each.value.default_action.type != "forward" ? [each.value.default_action] : []

    content {
      type  = default_action.value.type
      order = default_action.value.order != null ? default_action.value.order : null

      dynamic "fixed_response" {
        for_each = default_action.value.fixed_response != null ? [default_action.value.fixed_response] : []

        content {
          content_type = fixed_response.value.content_type
          message_body = fixed_response.value.message_body != null ? fixed_response.value.message_body : null
          status_code  = fixed_response.value.status_code
        }
      }

      dynamic "redirect" {
        for_each = default_action.value.redirect != null ? [default_action.value.redirect] : []

        content {
          protocol    = redirect.value.protocol != null ? redirect.value.protocol : null
          port        = redirect.value.port != null ? redirect.value.port : null
          host        = redirect.value.host != null ? redirect.value.host : null
          path        = redirect.value.path != null ? redirect.value.path : null
          query       = redirect.value.query != null ? redirect.value.query : null
          status_code = redirect.value.status_code != null ? redirect.value.status_code : null
        }
      }
    }
  }

  tags = merge(
    var.tags,
    each.value.tags
  )

  depends_on = [
    aws_lb.this,
    aws_lb_target_group.this
  ]
}