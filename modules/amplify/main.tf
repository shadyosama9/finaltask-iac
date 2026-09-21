resource "aws_amplify_app" "this" {
  for_each = var.amplify_apps

  # ─── Core Configuration ────────────────────────────────────────────
  name         = each.value.name
  repository   = each.value.repository
  platform     = "WEB"
  access_token = var.github_token

  # ─── IAM Configuration ────────────────────────────────────────────
  iam_service_role_arn = try(each.value.iam_service_role_arn, null)

  # ─── Environment Variables ─────────────────────────────────────────
  environment_variables = merge(
    lookup(local.app_secrets, each.key, {}),
    each.value.environment_variables
  )

  # ─── Auto Branch Settings ──────────────────────────────────────────
  enable_auto_branch_creation = each.value.enable_auto_branch_creation
  enable_branch_auto_deletion = each.value.enable_branch_auto_deletion

  ## Auto Branch Creation Configuration
  dynamic "auto_branch_creation_config" {
    for_each = each.value.auto_branch_creation_config != null ? [1] : []
    content {
      stage                  = each.value.auto_branch_creation_config.stage
      framework              = each.value.auto_branch_creation_config.framework
      enable_auto_build      = each.value.auto_branch_creation_config.enable_auto_build
      environment_variables  = each.value.auto_branch_creation_config.environment_variables
      basic_auth_credentials = each.value.auto_branch_creation_config.basic_auth_credentials
      enable_basic_auth      = each.value.auto_branch_creation_config.enable_basic_auth
    }
  }


  # ─── Redirect Rules ────────────────────────────────────────────────
  dynamic "custom_rule" {
    for_each = each.value.custom_rule
    content {
      source    = custom_rule.value.source
      target    = custom_rule.value.target
      status    = custom_rule.value.status
      condition = custom_rule.value.condition
    }
  }

  lifecycle {
    ignore_changes = [
      environment_variables
    ]
  }

  # ─── Resource Metadata ────────────────────────────────────────────
  tags = merge({
    Name = format("%s-%s-amplify", var.project, var.env)
  }, var.tags)
}



resource "aws_amplify_branch" "this" {
  for_each = var.amplify_branches

  # ─── Core Branch Configuration ─────────────────────────────────────
  app_id      = aws_amplify_app.this[each.value.name].id
  branch_name = each.value.branch_name
  framework   = each.value.framework
  stage       = each.value.stage

  # ─── Environment & Notifications ───────────────────────────────────
  environment_variables = each.value.environment_variables
  enable_auto_build     = each.value.enable_auto_build
  enable_notification   = each.value.enable_notification

  # ─── Resource Metadata ────────────────────────────────────────────
  tags = merge({
    Name = format("%s-%s-%s-branch", var.project, var.env, each.key)
  }, var.tags)

  depends_on = [aws_amplify_app.this]
}



resource "aws_amplify_domain_association" "this" {
  for_each = var.amplify_domains

  # ─── Domain Association ───────────────────────────────────────────
  app_id                = aws_amplify_app.this[each.value.app_name].id
  domain_name           = each.value.domain_name
  wait_for_verification = each.value.wait_for_verification

  # ─── Subdomain Mapping ─────────────────────────────────────────────
  dynamic "sub_domain" {
    for_each = each.value.subdomains
    content {
      branch_name = sub_domain.value.branch_name
      prefix      = sub_domain.value.subdomain_prefix
    }
  }

  # ─── Certificate Configuration ────────────────────────────────────
  certificate_settings {
    type                   = each.value.certificate_type
    custom_certificate_arn = each.value.custom_certificate_arn
  }

  depends_on = [aws_amplify_app.this, aws_amplify_branch.this]
}