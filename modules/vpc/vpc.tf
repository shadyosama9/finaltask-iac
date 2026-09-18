resource "aws_vpc" "this" {
  for_each = var.vpc

  cidr_block           = each.value.cidr_block
  enable_dns_hostnames = each.value.enable_dns_hostnames
  enable_dns_support   = each.value.enable_dns_support

  tags = merge({
    Name = format("%s-vpc", var.env) },
    var.tags
  )
}

