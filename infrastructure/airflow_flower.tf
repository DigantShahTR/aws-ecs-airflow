resource "aws_security_group" "flower" {
  name        = "${local.resource_prefix}-${var.project_name}-${var.stage}-flower-sg"
  description = "Allow all inbound traffic for Flower"
  vpc_id      = var.vpc

  ingress {
    from_port   = 5555
    to_port     = 5555
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.default_tags
}

resource "aws_ecs_task_definition" "flower" {
  family                   = "${local.resource_prefix}-${var.project_name}-${var.stage}-flower"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_iam_role.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512" # the valid CPU amount for 2 GB is from from 256 to 1024
  memory                   = "1024"

  container_definitions = <<EOF
[
  {
    "name": "airflow_flower",
    "image": "728336755756.dkr.ecr.us-east-1.amazonaws.com/a205526-airflow-fargate:init",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 5555,
        "hostPort": 5555
      }
    ],
    "command": [
        "flower"
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
            "awslogs-stream-prefix": "flower"
        }
    }
  }
]
EOF

    }
