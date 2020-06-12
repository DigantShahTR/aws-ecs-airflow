resource "aws_security_group" "scheduler" {
  name        = "${local.resource_prefix}-${var.project_name}-${var.stage}-scheduler-sg"
  description = "Airflow scheduler security group"
  vpc_id      = var.vpc

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.default_tags
}

resource "aws_ecs_task_definition" "scheduler" {
  family                   = "${local.resource_prefix}-${var.project_name}-${var.stage}-scheduler"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_iam_role.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024" # the valid CPU amount for 2 GB is from from 256 to 1024
  memory                   = "2048"

  container_definitions = <<EOF
[
  {
    "name": "airflow_scheduler",
    "image": ${replace(
jsonencode(
"${aws_ecr_repository.docker_repository.repository_url}:${var.image_version}",
),
"/\"([0-9]+\\.?[0-9]*)\"/",
"$1",
)} ,
    "essential": true,
    "command": [
        "scheduler"
    ],
    "environment": [
      {
        "name": "REDIS_HOST",
        "value": ${replace(
jsonencode(
aws_elasticache_cluster.celery_backend.cache_nodes[0].address,
),
"/\"([0-9]+\\.?[0-9]*)\"/",
"$1",
)}
      },
      {
        "name": "REDIS_PORT",
        "value": "6379"
      },
      {
        "name": "POSTGRES_HOST",
        "value": ${replace(
jsonencode(
aws_rds_cluster.airflow_fargate_sls[0].endpoint,
),
"/\"([0-9]+\\.?[0-9]*)\"/",
"$1",
)}
      },
      {
        "name": "POSTGRES_PORT",
        "value": "5432"
      },
      {
          "name": "POSTGRES_USER",
          "value": "airflow"
      },
      {
          "name": "POSTGRES_PASSWORD",
          "value": ${replace(
jsonencode(random_string.metadata_db_password.result),
"/\"([0-9]+\\.?[0-9]*)\"/",
"$1",
)}
      },
      {
          "name": "POSTGRES_DB",
          "value": "airflow"
      },
      {
        "name": "FERNET_KEY",
        "value": "k8IfvPBpKOoDZSBbqHOQCgJkhXU_Y2wjwLZbJmavcXQ="
      },
      {
        "name": "AIRFLOW_BASE_URL",
        "value": "https://airflow-fargate.tr-secops-nonprod.aws-int.thomsonreuters.com"
      },
      {
        "name": "ENABLE_REMOTE_LOGGING",
        "value": "False"
      },
      {
        "name": "STAGE",
        "value": "${var.stage}"
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "a205526-airflow-fargate/app",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "scheduler"
        }
    }
  }
]
EOF

    }
