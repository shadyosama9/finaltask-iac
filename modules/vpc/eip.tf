resource "aws_eip" "this" {
  for_each = local.eip

  domain            = each.value.domain
  instance          = each.value.instance
  network_interface = each.value.network_interface

  tags = merge({
    Name = format("%s-%s-%s-eip", var.project, var.env, each.key) },
    var.tags
  )

}