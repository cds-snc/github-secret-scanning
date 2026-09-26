locals {
  api_log_group_name = "/aws/lambda/${module.api.function_name}"
  api_log_group_arn  = "arn:aws:logs:${var.region}:${var.account_id}:log-group:${local.api_log_group_name}"
}

module "sentinel_forwarder" {
  source            = "github.com/cds-snc/terraform-modules//sentinel_forwarder?ref=v12.1.2"
  function_name     = "${var.product_name}-sentinel"
  billing_tag_value = var.billing_code

  # 270 or later: earlier versions are built for CPython 3.12 while the module
  # runs python3.13, so the v2 path fails on every invocation without raising
  # an error (aws-sentinel-connector-layer#302).
  layer_arn = "arn:aws:lambda:ca-central-1:283582579564:layer:aws-sentinel-connector-layer:270"

  # Kept so rollback is a config change: the layer ignores these once
  # dce_endpoint and dcr_config are set. They are removed with the v1 path.
  customer_id = var.log_analytics_workspace_id
  shared_key  = var.log_analytics_workspace_key

  # v2 (Logs Ingestion API). No stored secret: the Lambda's role mints a Cognito
  # token (sentinel_v2_cognito.tf) that Entra accepts for the managed identity
  # sentinel-forwarder-v2-aws-cognito. These name Azure resources in
  # cds-snc/sentinel and cds-snc/cds-azure-resources.
  dce_endpoint = "https://dce-sentinel-forwarder-v2-153n.canadacentral-1.ingest.monitor.azure.com"
  dcr_config = {
    AWSCloudWatchLog = {
      dcrImmutableId = "dcr-6eccfc9e7ef34cd293566d5073d551f6"
      streamName     = "Custom-AWSCloudWatchLog_v2_Input"
    }
  }
  azure_client_id                 = "9fd2a8dc-1698-4291-a71f-19ddc3cef71f"
  azure_tenant_id                 = "221ca1d3-b3f2-4346-8abc-88f802495c7d"
  cognito_identity_pool_id        = aws_cognito_identity_pool.sentinel_forwarder_v2.id
  cognito_developer_provider_name = local.sentinel_forwarder_cognito_developer_provider_name

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