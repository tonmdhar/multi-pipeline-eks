###############################################
# CloudWatch Dashboard
###############################################
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 1
        properties = {
          markdown = "# ${var.project_name} — ${upper(var.environment)} Environment"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 1
        width  = 12
        height = 6
        properties = {
          title   = "Node CPU Utilization"
          region  = "us-east-1"
          metrics = [
            ["ContainerInsights", "node_cpu_utilization", "ClusterName", var.cluster_name]
          ]
          period = 300
          stat   = "Average"
          yAxis  = { left = { min = 0, max = 100 } }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 1
        width  = 12
        height = 6
        properties = {
          title   = "Node Memory Utilization"
          region  = "us-east-1"
          metrics = [
            ["ContainerInsights", "node_memory_utilization", "ClusterName", var.cluster_name]
          ]
          period = 300
          stat   = "Average"
          yAxis  = { left = { min = 0, max = 100 } }
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 7
        width  = 8
        height = 6
        properties = {
          title   = "Running Pods"
          region  = "us-east-1"
          metrics = [
            ["ContainerInsights", "pod_number_of_running_pods", "ClusterName",
              var.cluster_name, "Namespace", var.project_name]
          ]
          period = 60
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 7
        width  = 8
        height = 6
        properties = {
          title   = "Pod Restarts"
          region  = "us-east-1"
          metrics = [
            ["ContainerInsights", "pod_number_of_container_restarts", "ClusterName",
              var.cluster_name, "Namespace", var.project_name]
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 7
        width  = 8
        height = 6
        properties = {
          title   = "Network (Bytes/sec)"
          region  = "us-east-1"
          metrics = [
            ["ContainerInsights", "pod_network_rx_bytes", "ClusterName", var.cluster_name,
              "Namespace", var.project_name],
            ["ContainerInsights", "pod_network_tx_bytes", "ClusterName", var.cluster_name,
              "Namespace", var.project_name]
          ]
          period = 300
          stat   = "Average"
        }
      }
    ]
  })
}