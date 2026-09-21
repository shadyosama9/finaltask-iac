data "aws_secretsmanager_secret_version" "fetch_secret" {
  for_each = {
    for app_key, app_value in var.amplify_apps :
    app_key => app_value if try(app_value.secret_arn != null && app_value.secret_arn != "", false)
  }
  secret_id = each.value.secret_arn
}

locals {
  app_secrets = {
    for app_key, secret_data in data.aws_secretsmanager_secret_version.fetch_secret :
    app_key => jsondecode(secret_data.secret_string)
  }
}