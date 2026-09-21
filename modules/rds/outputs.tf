output "rds_usernames" {
  description = "RDS usernames"
  value       = { for key, rds in var.rds : key => rds.username }
}

# output "rds_password" {
#   description = "RDS passwords"
#   value       = { for key, password in random_password.this : key => password.result }
#   sensitive   = true
# }

output "db_endpoint" {
  description = "RDS DB endpoints"
  value       = { for key, rds in aws_db_instance.main : key => rds.endpoint }

}

output "replica_endpoints" {
  description = "RDS read replica endpoints"
  value       = { for key, replica in aws_db_instance.replica : key => replica.endpoint }
}

output "replica_identifiers" {
  description = "RDS read replica identifiers"
  value       = { for key, replica in aws_db_instance.replica : key => replica.identifier }
}

output "subnet_group_names" {
  description = "Names of the RDS subnet groups"
  value       = { for key, group in aws_db_subnet_group.this : key => group.name }

}

output "rds_master_secret_arns" {
  description = "RDS master user Secrets Manager ARNs"
  value       = { for key, rds in aws_db_instance.main : key => rds.master_user_secret[0].secret_arn }
}