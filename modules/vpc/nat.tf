resource "aws_nat_gateway" "this" {
  for_each = local.vpc_nat

  allocation_id = aws_eip.this[each.value.eip_key].id
  subnet_id     = aws_subnet.this[each.value.subnet_key].id

  tags = merge({
    Name = var.env
    },
    var.tags
  )
}