locals {
  oidc_providers = merge(
    {
      for key, provider in aws_iam_openid_connect_provider.this :
      key => {
        arn = provider.arn
        url = provider.url
      }
    },
    var.existing_oidc_providers
  )

  provider_host = {
    for key, provider in local.oidc_providers :
    key => replace(provider.url, "https://", "")
  }

  flattened_policy_attachments = flatten([
    for role_name, role in var.roles : [
      for policy_arn in role.policy_arns : {
        role_name  = role_name
        policy_arn = policy_arn
      }
    ]
  ])

  flattened_inline_policies = flatten([
    for role_name, role in var.roles : [
      for policy_name, policy_doc in role.inline_policies : {
        role_name   = role_name
        policy_name = policy_name
        policy_doc  = policy_doc
      }
    ]
  ])
}
