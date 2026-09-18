output "role_arns" {
  value = {
    for role_name, role in aws_iam_role.this : role_name => role.arn
  }
}

output "instance_profile_names" {
  value = {
    for role_name, profile in aws_iam_instance_profile.this : role_name => profile.name
  }
}

output "policy_arns" {
  value = {
    for policy_name, policy in aws_iam_policy.this : policy_name => policy.arn
  }
}
