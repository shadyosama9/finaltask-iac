output "role_arns" {
  value = {
    for role_name, role in aws_iam_role.this : role_name => role.arn
  }
}

output "oidc_provider_arns" {
  value = {
    for key, provider in local.oidc_providers : key => provider.arn
  }
}
