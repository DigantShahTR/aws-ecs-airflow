locals {
  default_tags = {
    "tr:application-asset-insight-id" = var.asset_insight_id
    "tr:environment-type"             = var.aws_environment
    "tr:financial-identifier"         = var.financial_identifier
    "tr:resource-owner"               = var.resource_owner
  }

  resource_prefix     = "a${var.asset_insight_id}"
  permission_boundary = "arn:aws:iam::${var.aws_account_id}:policy/tr-permission-boundary"
}

