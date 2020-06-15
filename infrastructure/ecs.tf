# resource "aws_ecr_repository" "docker_repository" {
#   name = "${local.resource_prefix}-${var.project_name}-${var.stage}"
# }

# resource "aws_ecr_lifecycle_policy" "docker_repository_lifecycly" {
#   repository = aws_ecr_repository.docker_repository.name
#
#   policy = <<EOF
# {
#     "rules": [
#         {
#             "rulePriority": 1,
#             "description": "Keep only the latest 5 images",
#             "selection": {
#                 "tagStatus": "any",
#                 "countType": "imageCountMoreThan",
#                 "countNumber": 5
#             },
#             "action": {
#                 "type": "expire"
#             }
#         }
#     ]
# }
# EOF
#
# }

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${local.resource_prefix}-${var.project_name}-${var.stage}"
}

resource "aws_cloudwatch_log_group" "log_group" {
  # name = "${local.resource_prefix}-${var.log_group_name}/${var.project_name}-${var.stage}"
  name              = "a205526-airflow-fargate/app"
  retention_in_days = 5
  tags              = local.default_tags
}

resource "aws_iam_role" "ecs_task_iam_role" {
  name                 = "${local.resource_prefix}-${var.project_name}-${var.stage}-ecs-task-role"
  description          = "Allow ECS tasks to access AWS resources"
  path                 = var.iam_role_prefix
  permissions_boundary = var.permissions_boundary

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "ecs_task_policy" {
  name = "${local.resource_prefix}-${var.project_name}-${var.stage}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "attach_policy" {
role       = aws_iam_role.ecs_task_iam_role.name
policy_arn = aws_iam_policy.ecs_task_policy.arn
}
