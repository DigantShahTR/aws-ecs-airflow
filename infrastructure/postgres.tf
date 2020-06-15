resource "random_string" "metadata_db_password" {
  length  = 32
  upper   = true
  number  = true
  special = false
}

resource "aws_security_group" "postgres_public" {
  name        = "${local.resource_prefix}-${var.project_name}-${var.stage}-postgres-public-sg"
  description = "Allow all inbound for Postgres"
  vpc_id      = var.vpc


  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
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

# resource "aws_db_subnet_group" "airflow_subnet_group" {
#   name       = "${local.resource_prefix}-${var.project_name}-${var.stage}"
#   subnet_ids = ["subnet-03aa2d592c1a1bb36", "subnet-083a81ab365557eaa", "subnet-0fb2539df13358ad6"]
#
#   tags = "${local.default_tags}"
# }

# resource "aws_db_instance" "metadata_db" {
#   identifier = "${local.resource_prefix}-${var.project_name}-${var.stage}-postgres"
#
#   # database name
#   name                   = "${local.resource_prefix}-${var.project_name}"
#   instance_class         = "${var.metadata_db_instance_type}"
#   allocated_storage      = 20
#   engine                 = "postgres"
#   engine_version         = "10.6"
#   skip_final_snapshot    = true
#   publicly_accessible    = true
#   db_subnet_group_name   = "${var.db_subnet_group_name}"
#   vpc_security_group_ids = ["${aws_security_group.postgres_public.id}"]
#   username               = "${var.project_name}"
#   password               = "${random_string.metadata_db_password.result}"
#
#   tags = "${local.default_tags}"
# }

# ***********************************************************

# data "aws_ssm_parameter" "metabase_db_pass" {
#   name = "/a205526/databots/qa/MB_DB_PASS"
# }

## DATABOTS ANALYTICS USER SETTINGS DB ##
# resource "aws_rds_cluster" "databots_analytics_postgresql_cluster" {
#   count              = "1"
#   cluster_identifier = "${local.resource_prefix}-${var.project_name}-${var.stage}-cluster"
#   engine             = "aurora-postgresql"
#   availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
#   database_name      = var.project_name
#   master_username    = var.project_name
#
#   # master_password              = "${data.aws_ssm_parameter.metabase_db_pass.value}"
#   master_password = random_string.metadata_db_password.result
#
#   # backup_retention_period = 7
#
#   # preferred_backup_window      = "06:00-08:00"
#   # preferred_maintenance_window = "wed:04:00-wed:04:30"
#
#   # final_snapshot_identifier    = "${local.resource_prefix}-${var.project_name}-${var.stage}-final-snapshot"
#   skip_final_snapshot = true
#
#   # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
#   # force an interpolation expression to be interpreted as a list by wrapping it
#   # in an extra set of list brackets. That form was supported for compatibilty in
#   # v0.11, but is no longer supported in Terraform v0.12.
#   #
#   # If the expression in the following list itself returns a list, remove the
#   # brackets to avoid interpretation as a list of lists. If the expression
#   # returns a single list item then leave it as-is and remove this TODO comment.
#   # snapshot_identifier    = var.snapshot_id
#   vpc_security_group_ids = [aws_security_group.postgres_public.id]
#   storage_encrypted      = true
#   db_subnet_group_name   = "tr-vpc-1-db-subnetgroup"
#   tags                   = local.default_tags
# }

# resource "aws_rds_cluster_instance" "databots_analytics_postgresql_cluster_primary" {
#   count               = "1"
#   engine              = "aurora-postgresql"
#   identifier          = "${local.resource_prefix}-${var.project_name}-${var.stage}-primary"
#   cluster_identifier  = aws_rds_cluster.databots_analytics_postgresql_cluster[0].id
#   instance_class      = "db.r4.large"
#   publicly_accessible = true
#
#   # db_subnet_group_name = "tr-vpc-1-db-subnetgroup"
#   tags = local.default_tags
# }


resource "aws_rds_cluster" "airflow_fargate_sls" {
  count                   = 1
  cluster_identifier      = "${local.resource_prefix}-${var.project_name}-${var.stage}-serverless"
  skip_final_snapshot     = true
  engine                  = "aurora-postgresql"
  availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]
  database_name           = var.project_name
  master_username         = var.project_name
  master_password         = random_string.metadata_db_password.result
  backup_retention_period = 7
  # preferred_backup_window = var.sls_backup_window
  vpc_security_group_ids = [aws_security_group.postgres_public.id, "sg-01ec7f6604e27f96f"]
  engine_mode            = "serverless"
  deletion_protection    = false
  db_subnet_group_name   = "tr-vpc-1-db-subnetgroup"
  copy_tags_to_snapshot  = true
  tags                   = local.default_tags

  scaling_configuration {
    auto_pause               = true
    max_capacity             = 384
    min_capacity             = 2
    seconds_until_auto_pause = 300
  }
}
