module "cloudwatch_alarms_slack" {
  source = "github.com/cds-snc/terraform-modules//notify_slack?ref=v6.1.1"

  function_name     = "${var.product_name}-notify-slack"
  project_name      = var.product_name
  slack_webhook_url = var.slack_webhook_url
  sns_topic_arns = [
    local.sns_topic_arn,
  ]

  billing_tag_value = var.billing_code
}
