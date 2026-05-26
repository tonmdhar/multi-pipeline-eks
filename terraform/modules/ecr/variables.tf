variable "project_name" {
  description = "Project name for repository naming"
  type        = string
  default     = "atlas-platform"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "image_retention_count" {
  description = "Number of images to retain per repo"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
