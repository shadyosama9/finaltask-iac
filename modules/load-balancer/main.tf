resource "aws_lb" "this" {
  for_each = var.load_balancers

  name               = each.value.name
  internal           = each.value.internal
  load_balancer_type = each.value.load_balancer_type
  security_groups    = each.value.security_groups
  subnets            = each.value.subnets

  enable_deletion_protection = each.value.enable_deletion_protection


  tags = merge(
    var.tags,
    each.value.tags
  )
}