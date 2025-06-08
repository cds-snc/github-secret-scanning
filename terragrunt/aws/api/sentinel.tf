locals {
  api_log_group_name = "/aws/lambda/${module.api.function_name}"
  api_log_group_arn  = "arn:aws:logs:${var.region}:${var.account_id}:log-group:${local.api_log_group_name}"
}

module "sentinel_forwarder" {
  source            = "github.com/cds-snc/terraform-modules//sentinel_forwarder?ref=v10.4.7"
  function_name     = "${var.product_name}-sentinel"
  billing_tag_value = var.billing_code

  layer_arn = "arn:aws:lambda:ca-central-1:283582579564:layer:aws-sentinel-connector-layer:125"

  customer_id = var.log_analytics_workspace_id
  shared_key  = var.log_analytics_workspace_key

  cloudwatch_log_arns = [
    local.api_log_group_arn
  ]
}

resource "aws_cloudwatch_log_subscription_filter" "secret_detected" {
  name            = "Secret detected"
  log_group_name  = local.api_log_group_name
  filter_pattern  = "Secret detected"
  destination_arn = module.sentinel_forwarder.lambda_arn
  distribution    = "Random"
}