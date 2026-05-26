###############################################
# SNS Topic — Alarm Notifications
###############################################
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
  })
}

# Email subscriptions (each person gets alarm emails)
resource "aws_sns_topic_subscription" "email" {
  for_each = toset(var.alert_emails)

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = each.value
}

###############################################
# SNS Topic — Pipeline Notifications
###############################################
resource "aws_sns_topic" "pipeline" {
  name = "${var.project_name}-${var.environment}-pipeline-alerts"

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
  })
}

resource "aws_sns_topic_subscription" "pipeline_email" {
  for_each = toset(var.alert_emails)

  topic_arn = aws_sns_topic.pipeline.arn
  protocol  = "email"
  endpoint  = each.value
}

###############################################
# SNS Topic Policy — Allow CloudWatch to publish
###############################################
resource "aws_sns_topic_policy" "alerts" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudwatch.amazonaws.com" }
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.alerts.arn
    }]
  })
}
