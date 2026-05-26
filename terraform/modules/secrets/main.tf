###############################################
# Secrets Manager — one secret per app config
###############################################
resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "${var.project_name}/${var.environment}/app-secrets"
  description             = "Application secrets for ${var.project_name} (${var.environment})"
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
  })
}

# Store the actual secret values as JSON
resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id     = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode(var.secrets)
}

