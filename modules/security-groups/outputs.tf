output "security_group_ids" {
  value = {
    for name, security_group in aws_security_group.this :
    name => security_group.id
  }
}
