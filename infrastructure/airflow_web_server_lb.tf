# variable "route53_zone" {
#   description = "The name of the Route53 zone to search"
#   default     = "tr-secops-nonprod.aws-int.thomsonreuters.com."
# }

variable "ssl_policy" {
  default = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}

resource "aws_lb" "airflow_alb" {
  name               = "${local.resource_prefix}-${var.project_name}-${var.stage}-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = ["subnet-03aa2d592c1a1bb36", "subnet-083a81ab365557eaa", "subnet-0fb2539df13358ad6"]
  # security_groups    = [aws_security_group.application_load_balancer.id]
  security_groups = ["sg-09fa9cee284e5a71f", "sg-0eb32444c8d4f0280", "sg-417ab536"]
  tags            = local.default_tags
}

# resource "aws_lb_target_group" "airflow_web_server" {
#   name        = "${local.resource_prefix}-${var.project_name}-${var.stage}"
#   port        = 8080
#   protocol    = "HTTP"
#   vpc_id      = var.vpc
#   target_type = "ip"
#   tags        = local.default_tags
#
#   health_check {
#     interval = 10
#
#     # port     = 8080
#     protocol = "HTTP"
#     path     = "/health"
#     matcher  = "200-299"
#
#     # timeout             = 5
#     healthy_threshold   = 5
#     unhealthy_threshold = 10
#   }
#
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# port exposed from the application load balancer
resource "aws_lb_listener" "airflow_web_server" {
  load_balancer_arn = aws_lb.airflow_alb.id

  # port              = "80"
  # protocol          = "HTTP"
  port = 443

  protocol   = "HTTPS"
  ssl_policy = var.ssl_policy

  certificate_arn = "arn:aws:acm:us-east-1:728336755756:certificate/ab019ee9-dd55-4c93-a2c0-84f56e79b926"

  default_action {
    target_group_arn = aws_lb_target_group.airflow_web_server.id
    type             = "forward"
  }
}

resource "aws_route53_record" "regional" {
  zone_id = "Z2E6DT30PKEU3R"
  name    = "airflow-fargate"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_lb.airflow_alb.dns_name]
}
