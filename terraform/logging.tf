### logging
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/dagster-ecs-cluster" # Ensure this matches the awslogs-group defined in your task definition

  # Optionally, specify a retention in days, e.g., 30 days
  retention_in_days = 1

  tags = {
    Name = "dagsterECSLogs"
  }
}

# Create policy for logs streaming
resource "aws_iam_policy" "ecs_cloudwatch_logs_policy" {
  name        = "ECSCloudWatchLogsPolicy"
  description = "Allow ECS tasks to create and push logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_cloudwatch_logs_policy_attachment" {
  name       = "ECS-CloudWatch-Logs-Policy-Attachment"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = aws_iam_policy.ecs_cloudwatch_logs_policy.arn
}