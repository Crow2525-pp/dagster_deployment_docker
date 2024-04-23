resource "aws_secretsmanager_secret" "aws_credentials" {
  name        = "aws_credentials"
  description = "AWS credentials for accessing specific services"

  tags = {
    "dagster" = "dagster"
  }
}

resource "aws_secretsmanager_secret_version" "main" {
  secret_id     = aws_secretsmanager_secret.aws_credentials.id
  secret_string = jsonencode({
    AWS_ACCESS_KEY_ID     = var.aws_access_key_id,
    AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
  })
}

output "aws_credentials_secret_arn" {
  description = "The ARN of the AWS credentials secret"
  value       = aws_secretsmanager_secret.aws_credentials.arn
}