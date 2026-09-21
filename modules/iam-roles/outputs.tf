output "role_arns" {
  value = {
    for role_name, role in aws_iam_role.this : role_name => role.arn
  }
}
