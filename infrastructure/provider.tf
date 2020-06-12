terraform {
  required_version = ">=0.12.0" #, <0.12.3"

  backend "s3" {
    # profile = "tr-isrm-services-nonprod"
    # bucket = "a205526-airflow-terraform"
    # key     = "infra/PreProd/us-east-1/airflow_infra.tfstate"
    key = "infra/airflow_fargate_infra.tfstate"

    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  version = "~> 2.65.0"
  region  = "us-east-1"
}
