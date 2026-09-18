resource "aws_acm_certificate" "this" {
  for_each          = var.acm
  domain_name       = each.value.domain_name
  validation_method = each.value.validation_method
  tags              = var.tags
}
