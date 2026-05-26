output "alerts_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  value       = aws_sns_topic.alerts.arn
}

output "pipeline_topic_arn" {
  description = "SNS topic ARN for pipeline notifications"
  value       = aws_sns_topic.pipeline.arn
}

output "alerts_topic_name" {
  description = "SNS topic name"
  value       = aws_sns_topic.alerts.name
}
