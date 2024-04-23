provider "aws" {
  region = "eu-central-1"  # Change to your desired region
}


# Create ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "dagster-ecs-cluster"  # Change cluster name if needed
}

# Define ECS task definition for Fargate
resource "aws_ecs_task_definition" "dagster_control_plane_task_definition" {
  family                   = "dagster-task-family"  # Change task family name if needed
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  
  cpu = 512  # CPU units (in 1/1024 vCPU)
  memory = 2048  # Memory in MiB

  container_definitions = jsonencode([
    {
      name      = "dagster-webserver"
      image     = "123123123.dkr.ecr.eu-central-1.amazonaws.com/deploy_ecs/webserver:latest"
      essential = true,
      entryPoint = [
        "dagster-webserver",
        "-h", "0.0.0.0",
        "-p", "3000",
        "-w", "workspace.yaml"
      ],
      environment = [
        {
          name  = "DAGSTER_POSTGRES_HOSTNAME",
          value = aws_db_instance.dagster_postgres_db.address
        },
        {
          name  = "DAGSTER_POSTGRES_USER",
          value = "postgres_user"
        },
        {
          name  = "DAGSTER_POSTGRES_PASSWORD",
          value = "postgres_password"
        },
        {
          name  = "DAGSTER_POSTGRES_DB",
          value = "postgres_db"
        }
      ],
      portMappings = [
        {
          containerPort = 3000,
          hostPort      = 3000
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "/ecs/dagster-ecs-cluster",
          "awslogs-region"        = "eu-central-1",
          "awslogs-stream-prefix" = "webserver"
        }
      }
    },
    {
      name      = "dagster-daemon"
      image     = "123123123.dkr.ecr.eu-central-1.amazonaws.com/deploy_ecs/daemon:latest"
      essential = true,
      entryPoint = [
        "dagster-daemon",
        "run",
      ],
      environment = [
        {
          name  = "DAGSTER_POSTGRES_HOSTNAME",
          value = aws_db_instance.dagster_postgres_db.address
        },
        {
          name  = "DAGSTER_POSTGRES_USER",
          value = "postgres_user"
        },
        {
          name  = "DAGSTER_POSTGRES_PASSWORD",
          value = "postgres_password"
        },
        {
          name  = "DAGSTER_POSTGRES_DB",
          value = "postgres_db"
        },
        {
          name  = "DATABASE_IP",
          value = aws_db_instance.dagster_postgres_db.address
        },
        {
          name  = "DATABASE_PORT",
          value = "5432"
        },
        {
          name  = "DATABASE_USER",
          value = "postgres_user"
        },
        {
          name  = "DATABASE_PASSWORD",
          value = "postgres_password"
        },
        {
          name  = "DATABASE_NAME",
          value = "postgres_db"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "/ecs/dagster-ecs-cluster",
          "awslogs-region"        = "eu-central-1",
          "awslogs-stream-prefix" = "daemon"
        }
      },
      secrets = [
        {
          name      = "AWS_ACCESS_KEY_ID"
          valueFrom = "${aws_secretsmanager_secret.aws_credentials.arn}:AWS_ACCESS_KEY_ID::"
        },
        {
          name      = "AWS_SECRET_ACCESS_KEY"
          valueFrom = "${aws_secretsmanager_secret.aws_credentials.arn}:AWS_SECRET_ACCESS_KEY::"
        }
      ]
    },
    {
      name      = "pipeline-x"
      image     = "123123123.dkr.ecr.eu-central-1.amazonaws.com/deploy_ecs/pipeline-x:latest"
      essential = true,
      portMappings = [
        {
          containerPort = 4000,
          hostPort      = 4000
        }
      ],
      entryPoint = [
        "dagster",
        "api", "grpc",
        "-h" ,"0.0.0.0",
        "-p", "4000",
        "-m", "pipeline_x"
      ],
      environment = [
        {
          name  = "DAGSTER_POSTGRES_HOSTNAME",
          value = aws_db_instance.dagster_postgres_db.address
        },
        {
          name  = "DAGSTER_POSTGRES_USER",
          value = "postgres_user"
        },
        {
          name  = "DAGSTER_POSTGRES_PASSWORD",
          value = "postgres_password"
        },
        {
          name  = "DAGSTER_POSTGRES_DB",
          value = "postgres_db"
        },
        {
          name  = "DATABASE_IP",
          value = aws_db_instance.dagster_postgres_db.address 
        },
        {
          name  = "DATABASE_PORT",
          value = "5432"
        },
        {
          name  = "DATABASE_USER",
          value = "postgres_user"
        },
        {
          name  = "DATABASE_PASSWORD",
          value = "postgres_password"
        },
        {
          name  = "DATABASE_NAME",
          value = "postgres_db"
        },
        {
          name  = "DAGSTER_CURRENT_IMAGE",
          value = "123123123.dkr.ecr.eu-central-1.amazonaws.com/deploy_ecs/pipeline-x:latest"
        },
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "/ecs/dagster-ecs-cluster",
          "awslogs-region"        = "eu-central-1",
          "awslogs-stream-prefix" = "pipeline-x"
        }
      },
      secrets = [
        {
          name      = "AWS_ACCESS_KEY_ID"
          valueFrom = "${aws_secretsmanager_secret.aws_credentials.arn}:AWS_ACCESS_KEY_ID::"
        },
        {
          name      = "AWS_SECRET_ACCESS_KEY"
          valueFrom = "${aws_secretsmanager_secret.aws_credentials.arn}:AWS_SECRET_ACCESS_KEY::"
        }
      ]

    },
    {
      name      = "pipeline-y"
      image     = "123123123.dkr.ecr.eu-central-1.amazonaws.com/deploy_ecs/pipeline-y:latest"
      essential = true,
      portMappings = [
        {
          containerPort = 4047,
          hostPort      = 4047
        }
      ],
      entryPoint = [
        "dagster",
        "api", "grpc",
        "-h" ,"0.0.0.0",
        "-p", "4047",
        "-m", "pipeline_y"
      ],
      environment = [
        {
          name  = "DAGSTER_POSTGRES_HOSTNAME",
          value = aws_db_instance.dagster_postgres_db.address
        },
        {
          name  = "DAGSTER_POSTGRES_USER",
          value = "postgres_user"
        },
        {
          name  = "DAGSTER_POSTGRES_PASSWORD",
          value = "postgres_password"
        },
        {
          name  = "DAGSTER_POSTGRES_DB",
          value = "postgres_db"
        },
        {
          name  = "DATABASE_IP",
          value = aws_db_instance.dagster_postgres_db.address 
        },
        {
          name  = "DATABASE_PORT",
          value = "5432"
        },
        {
          name  = "DATABASE_USER",
          value = "postgres_user"
        },
        {
          name  = "DATABASE_PASSWORD",
          value = "postgres_password"
        },
        {
          name  = "DATABASE_NAME",
          value = "postgres_db"
        },
        {
          name  = "DAGSTER_CURRENT_IMAGE",
          value = "123123123.dkr.ecr.eu-central-1.amazonaws.com/deploy_ecs/pipeline-y:latest"
        },
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "/ecs/dagster-ecs-cluster",
          "awslogs-region"        = "eu-central-1",
          "awslogs-stream-prefix" = "pipeline-y"
        }
      },
      secrets = [
        {
          name      = "AWS_ACCESS_KEY_ID"
          valueFrom = "${aws_secretsmanager_secret.aws_credentials.arn}:AWS_ACCESS_KEY_ID::"
        },
        {
          name      = "AWS_SECRET_ACCESS_KEY"
          valueFrom = "${aws_secretsmanager_secret.aws_credentials.arn}:AWS_SECRET_ACCESS_KEY::"
        }
      ]

    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

### roles
# Create IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "dagsterEcsTaskExecutionRole"  # Change role name if needed
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Define IAM policy for ECS task execution
resource "aws_iam_policy" "ecs_task_execution_policy" {
  name        = "dagsterEcsTaskExecutionPolicy"  # Change policy name if needed
  description = "Policy for ECS task execution role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = [
          "ecs:DescribeTasks",
          "ecs:StopTask",
          "ec2:DescribeNetworkInterfaces",
          "ecs:DescribeTaskDefinition",
          "ecs:ListAccountSettings",
          "ecs:RegisterTaskDefinition",
          "ecs:RunTask",
          "ecs:TagResource",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets",
          "secretsmanager:GetSecretValue",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Resource  = "*"
      },
      {
        Effect    = "Allow",
        Action    = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource  = [
          "arn:aws:s3:::etl-dagster-data",
          "arn:aws:s3:::etl-dagster-data/*"
        ]
      }
    ]
  })
}

# Attach IAM policy to ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}

# Create ECS service to deploy the task definition
resource "aws_ecs_service" "dagster_webserver_ecs_service" {
  name            = "dagster-webserver-ecs-service"  # Change service name if needed
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.dagster_control_plane_task_definition.arn
  desired_count   = 1  # Number of tasks to run
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.dagster_subnet.id]  # Replace with your subnet ID
    security_groups  = [aws_security_group.dagster_sg.id]  # Replace with your security group ID
    assign_public_ip = true
  }

    depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution_attachment,
  ]
}

# Outputs
output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

# Outputs
output "ecs_task_execution_role" {
  value = aws_iam_role.ecs_task_execution_role.arn
}