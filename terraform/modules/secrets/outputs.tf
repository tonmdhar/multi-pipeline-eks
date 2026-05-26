output "secret_arn" {
  description = "ARN of the secrets manager secret"
  value       = aws_secretsmanager_secret.app_secrets.arn
}

output "secret_name" {
  description = "Name of the secret"
  value       = aws_secretsmanager_secret.app_secrets.name
}

output "secrets_read_policy_arn" {
  description = "IAM policy ARN for pods to read secrets"
  value       = aws_iam_policy.secrets_read.arn
}