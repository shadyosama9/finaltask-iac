output "key_arns" {
  description = "ARNs of the created KMS keys, keyed by logical name"
  value       = { for k, v in aws_kms_key.this : k => v.arn }
}

output "key_ids" {
  description = "IDs of the created KMS keys, keyed by logical name"
  value       = { for k, v in aws_kms_key.this : k => v.key_id }
}
