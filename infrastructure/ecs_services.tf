resource "aws_ecs_service" "web_server_service" {
  name                               = "${local.resource_prefix}-${var.project_name}-${var.stage}-web-server"
  cluster                            = aws_ecs_cluster.ecs_cluster.id
  task_definition                    = aws_ecs_task_definition.web_server.arn
  desired_count                      = 1
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 60

  network_configuration {
    security_groups = [aws_security_group.web_server_ecs_internal.id, "sg-0b7a5fc65e1d91890", "sg-417ab536", "sg-0f4214afda15a56ea", "sg-4e14c739"]
    # subnets          = ["subnet-03aa2d592c1a1bb36", "subnet-083a81ab365557eaa", "subnet-0fb2539df13358ad6"]
    subnets          = ["subnet-0dff2e23", "subnet-600ddd07", "subnet-a6a275fa"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.airflow_web_server.id
    container_name   = "airflow_web_server"
    container_port   = 8080
  }

  # depends_on = [
  #   "aws_db_instance.metadata_db",
  #   "aws_elasticache_cluster.celery_backend",
  #   "aws_lb_listener.airflow_web_server",
  # ]
  depends_on = [
    aws_rds_cluster.airflow_fargate_sls,
    aws_elasticache_cluster.celery_backend,
    aws_lb_listener.airflow_web_server,
  ]
}

resource "aws_ecs_service" "scheduler_service" {
  name            = "${local.resource_prefix}-${var.project_name}-${var.stage}-scheduler"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.scheduler.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.scheduler.id, "sg-0b7a5fc65e1d91890", "sg-417ab536", "sg-0f4214afda15a56ea", "sg-4e14c739"]
    # subnets          = ["subnet-03aa2d592c1a1bb36", "subnet-083a81ab365557eaa", "subnet-0fb2539df13358ad6"]
    subnets          = ["subnet-0dff2e23", "subnet-600ddd07", "subnet-a6a275fa"]
    assign_public_ip = true # when using a NAT can be put to false, or when ECS Private Link is enabled
  }

  depends_on = [
    aws_rds_cluster.airflow_fargate_sls,
    aws_elasticache_cluster.celery_backend,
  ]
  # depends_on = [
  #   "aws_db_instance.metadata_db",
  #   "aws_elasticache_cluster.celery_backend",
  # ]
}

resource "aws_ecs_service" "workers_service" {
  name            = "${local.resource_prefix}-${var.project_name}-${var.stage}-workers"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.workers.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.workers.id, "sg-0b7a5fc65e1d91890", "sg-417ab536", "sg-0f4214afda15a56ea", "sg-4e14c739"]
    # subnets          = ["subnet-03aa2d592c1a1bb36", "subnet-083a81ab365557eaa", "subnet-0fb2539df13358ad6"]
    subnets          = ["subnet-0dff2e23", "subnet-600ddd07", "subnet-a6a275fa"]
    assign_public_ip = true # when using a NAT can be put to false, or when ECS Private Link is enabled
  }

  depends_on = [
    aws_rds_cluster.airflow_fargate_sls,
    aws_elasticache_cluster.celery_backend,
  ]
  # depends_on = [
  #   "aws_db_instance.metadata_db",
  #   "aws_elasticache_cluster.celery_backend",
  # ]
}

resource "aws_ecs_service" "flower_service" {
  name            = "${local.resource_prefix}-${var.project_name}-${var.stage}-flower"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.flower.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.flower.id, "sg-0b7a5fc65e1d91890", "sg-417ab536", "sg-0f4214afda15a56ea", "sg-4e14c739"]
    # subnets          = ["subnet-03aa2d592c1a1bb36", "subnet-083a81ab365557eaa", "subnet-0fb2539df13358ad6"]
    subnets          = ["subnet-0dff2e23", "subnet-600ddd07", "subnet-a6a275fa"]
    assign_public_ip = true
  }

  depends_on = [
    aws_rds_cluster.airflow_fargate_sls,
    aws_elasticache_cluster.celery_backend,
  ]
  # depends_on = [
  #   "aws_db_instance.metadata_db",
  #   "aws_elasticache_cluster.celery_backend",
  # ]
}
