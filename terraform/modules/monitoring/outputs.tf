output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "log_group_container_insights" {
  description = "Container Insights log group name"
  value       = aws_cloudwatch_log_group.eks_container_insights.name
}

output "log_group_application" {
  description = "Application log group name"
  value       = aws_cloudwatch_log_group.application.name
}

output "alarm_arns" {
  description = "All alarm ARNs"
  value = [
    aws_cloudwatch_metric_alarm.node_cpu_high.arn,
    aws_cloudwatch_metric_alarm.node_memory_high.arn,
    aws_cloudwatch_metric_alarm.pod_restarts.arn,
    aws_cloudwatch_metric_alarm.no_running_pods.arn,
    aws_cloudwatch_metric_alarm.node_not_ready.arn,
  ]
}
