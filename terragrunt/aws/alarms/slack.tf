module "cloudwatch_alarms_slack" {
  source = "github.com/cds-snc/terraform-modules?ref=v5.0.2//notify_slack"

  function_name     = var.product_name
  project_name      = var.product_name
  slack_webhook_url = var.slack_webhook_url
  sns_topic_arns = [
    local.sns_topic_arn,
  ]

  billing_tag_value = var.billing_code
}
