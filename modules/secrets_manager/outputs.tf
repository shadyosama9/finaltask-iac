output "secret_arn" {
  description = "The ARN of the created secret"
  value = {
    for key, secret in aws_secretsmanager_secret.this : key => secret.arn
  }

}

# output "secret_manager_endpoint_id" {
#   description = "The ID of the Secrets Manager VPC endpoint"
#   value       = { for k, v in aws_vpc_endpoint.this : k => v.id }

# }

# output "secret_manager_endpoint_dns" {
#   description = "The DNS name of the Secrets Manager VPC endpoint"
#   value       = aws_vpc_endpoint.this.dns_entry

# }