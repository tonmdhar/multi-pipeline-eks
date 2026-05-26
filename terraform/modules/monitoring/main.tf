###############################################
# Enable Container Insights on EKS
# (Collects pod/node metrics to CloudWatch)
###############################################
resource "aws_cloudwatch_log_group" "eks_container_insights" {
  name              = "/aws/containerinsights/${var.cluster_name}/performance"
  retention_in_days = var.environment == "prod" ? 30 : 7

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/eks/${var.cluster_name}/${var.project_name}"
  retention_in_days = var.environment == "prod" ? 30 : 7

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

###############################################
# Alarm: High CPU on Nodes
###############################################
resource "aws_cloudwatch_metric_alarm" "node_cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-node-cpu-high"
  alarm_description   = "EKS node CPU utilization above ${var.cpu_alarm_threshold}%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

###############################################
# Alarm: High Memory on Nodes
###############################################
resource "aws_cloudwatch_metric_alarm" "node_memory_high" {
  alarm_name          = "${var.project_name}-${var.environment}-node-memory-high"
  alarm_description   = "EKS node memory utilization above ${var.memory_alarm_threshold}%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "node_memory_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = var.memory_alarm_threshold

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

###############################################
# Alarm: Pod Restart Count (crash loop detection)
###############################################
resource "aws_cloudwatch_metric_alarm" "pod_restarts" {
  alarm_name          = "${var.project_name}-${var.environment}-pod-restarts-high"
  alarm_description   = "Pod restarts exceeded ${var.pod_restart_threshold} in 5 minutes —possible crash loop"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "pod_number_of_container_restarts"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Maximum"
  threshold           = var.pod_restart_threshold

  dimensions = {
    ClusterName = var.cluster_name
    Namespace   = var.project_name
  }

  alarm_actions = [var.sns_topic_arn]

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

###############################################
# Alarm: No Running Pods (complete outage)
###############################################
resource "aws_cloudwatch_metric_alarm" "no_running_pods" {
  alarm_name          = "${var.project_name}-${var.environment}-no-running-pods"
  alarm_description   = "CRITICAL: Zero running pods detected — service is DOWN"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "pod_number_of_running_pods"
  namespace           = "ContainerInsights"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1

  dimensions = {
    ClusterName = var.cluster_name
    Namespace   = var.project_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

###############################################
# Alarm: Node Not Ready
###############################################
resource "aws_cloudwatch_metric_alarm" "node_not_ready" {
  alarm_name          = "${var.project_name}-${var.environment}-node-not-ready"
  alarm_description   = "EKS node is in NotReady state"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "cluster_failed_node_count"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = merge(var.tags, {
    Environment = var.environment
  })
}
