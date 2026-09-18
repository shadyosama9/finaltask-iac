output "cert_arn" {
  value = {
    for k, v in aws_acm_certificate.this :
    k => v.arn
  }
}

output "cert_validation_dns_records" {
  value = {
    for k, cert in aws_acm_certificate.this :
    k => {
      name  = tolist(cert.domain_validation_options)[0].resource_record_name
      type  = tolist(cert.domain_validation_options)[0].resource_record_type
      value = tolist(cert.domain_validation_options)[0].resource_record_value
    }
  }
}