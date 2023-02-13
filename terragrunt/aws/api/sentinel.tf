module "sentinel_forwarder" {
  source            = "github.com/cds-snc/terraform-modules?ref=v5.0.1//sentinel_forwarder"
  function_name     = "${var.product_name}-sentinel-forwarder"
  billing_tag_value = var.billing_code

  customer_id = var.log_analytics_workspace_id
  shared_key  = var.log_analytics_workspace_key

  cloudwatch_log_arns = [
    "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/${module.api.function_name}"
  ]
}
