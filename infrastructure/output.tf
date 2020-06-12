output "metadata_db_postgres_password" {
  value = random_string.metadata_db_password.result
}

# output "metadata_db_postgres_endpoint" {
#   value = "${aws_db_instance.metadata_db.endpoint}"
# }
#
# output "metadata_db_postgres_address" {
#   value = "${aws_db_instance.metadata_db.address}"
# }

output "celery_backend_address" {
  value = aws_elasticache_cluster.celery_backend.cache_nodes[0].address
}

output "airflow_web_server_endpoint" {
  value = aws_lb.airflow_alb.dns_name
}

# output "metadata_db_postgres_endpoint" {
#   value       = aws_rds_cluster.databots_analytics_postgresql_cluster[0].endpoint
#   description = "The DNS address of the RDS instance"
# }

output "metadata_db_postgres_address" {
  value       = aws_rds_cluster.airflow_fargate_sls[0].endpoint
  description = "The DNS address of the RDS instance"
}
