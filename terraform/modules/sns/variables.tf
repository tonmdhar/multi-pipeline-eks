variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "atlas-platform"
}

variable "alert_emails" {
  description = "Email addresses to receive alarm notifications"
  type        = list(string)
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
