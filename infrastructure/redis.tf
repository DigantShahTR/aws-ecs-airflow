resource "aws_security_group" "redis_vpc" {
  name        = "${local.resource_prefix}-${var.project_name}-${var.stage}-redis-vpc-sg"
  description = "Allow all inbound traffic"
  vpc_id      = var.vpc

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["${var.base_cidr_block}/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.default_tags
}

resource "aws_elasticache_subnet_group" "airflow_redis_subnet_group" {
  name       = "${local.resource_prefix}-${var.project_name}-${var.stage}"
  subnet_ids = ["subnet-03aa2d592c1a1bb36", "subnet-083a81ab365557eaa", "subnet-0fb2539df13358ad6"]
}

resource "aws_elasticache_cluster" "celery_backend" {
  cluster_id         = "${local.resource_prefix}-airfargate"
  engine             = "redis"
  engine_version     = "4.0.10"
  node_type          = var.celery_backend_instance_type
  num_cache_nodes    = 1
  port               = "6379"
  subnet_group_name  = aws_elasticache_subnet_group.airflow_redis_subnet_group.id
  security_group_ids = [aws_security_group.redis_vpc.id]
}

