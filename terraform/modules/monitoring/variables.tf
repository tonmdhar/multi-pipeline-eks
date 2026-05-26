variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "atlas-platform"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  type        = string
}

variable "node_group_name" {
  description = "EKS node group name"
  type        = string
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization threshold for alarm (%)"
  type        = number
  default     = 80
}

variable "memory_alarm_threshold" {
  description = "Memory utilization threshold for alarm (%)"
  type        = number
  default     = 85
}

variable "pod_restart_threshold" {
  description = "Pod restart count threshold for alarm"
  type        = number
  default     = 5
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
