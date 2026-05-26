output "pipeline_name" {
  description = "CodePipeline name"
  value       = aws_codepipeline.this.name
}

output "pipeline_arn" {
  description = "CodePipeline ARN"
  value       = aws_codepipeline.this.arn
}

output "artifacts_bucket" {
  description = "S3 bucket for pipeline artifacts"
  value       = aws_s3_bucket.artifacts.bucket
}

output "codebuild_build_name" {
  description = "CodeBuild build project name"
  value       = aws_codebuild_project.build.name
}

output "codebuild_deploy_name" {
  description = "CodeBuild deploy project name"
  value       = aws_codebuild_project.deploy.name
}

output "codebuild_role_arn" {
  description = "CodeBuild IAM role ARN (grant EKS access to this)"
  value       = aws_iam_role.codebuild.arn
}