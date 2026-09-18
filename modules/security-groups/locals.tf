locals {
  ingress_rules_flattened = merge([
    for sg_name, sg_config in var.security_groups : {
      for idx, rule in sg_config.ingress_rules :
      "${sg_name}_ingress_${idx}" => {
        sg_name = sg_name
        rule    = rule
      }
    }
  ]...)

  egress_rules_flattened = merge([
    for sg_name, sg_config in var.security_groups : {
      for idx, rule in sg_config.egress_rules :
      "${sg_name}_egress_${idx}" => {
        sg_name = sg_name
        rule    = rule
      }
    }
  ]...)
}
