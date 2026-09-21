output "branch_urls" {
  description = "Amplify-generated branch URLs keyed by branch map key"
  value = {
    for k, branch in aws_amplify_branch.this :
    k => "${lower(branch.branch_name)}.${aws_amplify_app.this[var.amplify_branches[k].name].default_domain}"
  }
}

output "app_arns" {
  description = "Amplify app ARNs keyed by app map key"
  value       = { for k, app in aws_amplify_app.this : k => app.arn }
}
