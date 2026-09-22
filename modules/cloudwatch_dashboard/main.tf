resource "aws_cloudwatch_dashboard" "this" {
  for_each = var.dashboards

  # ─── Core Configuration ──────────────────────────────────────────
  dashboard_name = each.value.dashboard_name
  dashboard_body = each.value.dashboard_body

}
