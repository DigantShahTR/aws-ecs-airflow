variable "aws_region" {
  default = "us-east-1"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "project_name" {
  default = "airflow"
}

variable "stage" {
  default = "fargate"
}

variable "base_cidr_block" {
  default = "10.0.0.0"
}

variable "log_group_name" {
  default = "ecs/fargate"
}

variable "image_version" {
  default = "latest"
}

variable "metadata_db_instance_type" {
  default = "db.t3.micro"
}

variable "celery_backend_instance_type" {
  default = "cache.t2.small"
}

variable "asset_insight_id" {
  default = "205526"
}

variable "aws_account_id" {
  default = "728336755756"
}

variable "aws_environment" {
  default = "PreProd"
}

variable "app_environment" {
  default = "dev"
}

variable "financial_identifier" {
  default = "589893527"
}

variable "app_name" {
  default = "airflow-fargate"
}

variable "resource_owner" {
  default = "digant.shah@thomsonreuters.com"
}

variable "vpc" {
  default = "vpc-53756d2b"
}

variable "iam_role_prefix" {
  default = "/service-role/"
}

variable "permissions_boundary" {
  default = "arn:aws:iam::728336755756:policy/tr-permission-boundary"
}

variable "db_subnet_group_name" {
  default = "tr-vpc-1-db-subnetgroup"
}

