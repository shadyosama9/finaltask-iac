resource "aws_cloudwatch_log_group" "flow_logs" {
  for_each = var.flow_logs

  name              = "/aws/vpc-flow-logs/${each.key}"
  retention_in_days = each.value.retention_days

  tags = merge({
    Name = each.key
  }, var.tags)
}

resource "aws_iam_role" "flow_logs" {
  for_each = var.flow_logs

  name = "${each.key}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "flow_logs" {
  for_each = var.flow_logs

  name = "${each.key}-policy"
  role = aws_iam_role.flow_logs[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_flow_log" "this" {
  for_each = var.flow_logs

  vpc_id          = aws_vpc.this[each.value.vpc_key].id
  traffic_type    = each.value.traffic_type
  iam_role_arn    = aws_iam_role.flow_logs[each.key].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[each.key].arn

  tags = merge({
    Name = each.key
  }, var.tags)
}
