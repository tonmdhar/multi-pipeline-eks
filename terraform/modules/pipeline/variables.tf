variable "project_name" {
  description = "Project name"
  type        = string
  default     = "atlas-platform"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "Branch to trigger pipeline"
  type        = string
  default     = "main"
}

variable "codestar_connection_arn" {
  description = "ARN of the CodeStar connection to GitHub"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL for pushing images"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name for deployment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for CodeBuild networking"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for CodeBuild"
  type        = list(string)
}

variable "require_approval" {
  description = "Require manual approval before deploy (use for prod)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "cluster_security_group_id" {
  description = "EKS cluster security group ID (for CodeBuild access)"
  type        = string
}
