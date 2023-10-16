#
# SNS: topics
#
resource "aws_sns_topic" "cloudwatch_alarm" {
  name              = "github-secret-scanning-cloudwatch-alarm"
  kms_master_key_id = aws_kms_key.sns_cloudwatch.id

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

#
# SNS: subscriptions
#
resource "aws_sns_topic_subscription" "cloudwatch_alarm" {
  topic_arn = aws_sns_topic.cloudwatch_alarm.arn
  protocol  = "https"
  endpoint  = var.slack_webhook_url
}

# SNS subscription for OpsGenie
resource "aws_sns_topic_subscription" "alert_to_sns_to_opsgenie" {
  topic_arn              = aws_sns_topic.cloudwatch_alarm.arn
  protocol               = "https"
  endpoint               = var.opsgenie_alarm_webhook_url
  raw_message_delivery   = false
  endpoint_auto_confirms = true
}

#
# KMS: SNS topic encryption keys
#
resource "aws_kms_key" "sns_cloudwatch" {
  # checkov:skip=CKV_AWS_7: key rotation not required for CloudWatch SNS topic's messages
  description = "KMS key for CloudWatch alarm SNS topic"
  policy      = data.aws_iam_policy_document.sns_cloudwatch.json

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

data "aws_iam_policy_document" "sns_cloudwatch" {
  # checkov:skip=CKV_AWS_109: `resources = ["*"]` identifies the KMS key to which the key policy is attached
  # checkov:skip=CKV_AWS_111: `resources = ["*"]` identifies the KMS key to which the key policy is attached
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
  }
}
