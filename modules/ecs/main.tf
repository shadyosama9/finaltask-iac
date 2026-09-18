resource "aws_ecs_cluster" "this" {
  for_each = var.ecs

  name = each.value.name

  tags = merge(
    var.tags,
    each.value.tags
  )

}