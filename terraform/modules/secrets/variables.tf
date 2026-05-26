variable "project_name" {
  description = "Project name"
  type        = string
  default     = "atlas-platform"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "secrets" {
  description = "Map of secret names to their values"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "recovery_window_in_days" {
  description = "Number of days before secret is permanently deleted"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}