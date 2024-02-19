# IAM Role for Lambda Function
resource "aws_iam_role" "group_broadcast_alert_role" {
  name = "group_broadcast_alert_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
      },
    ],
  })

  inline_policy {
    name = "lambda_permissions"
    policy = data.aws_iam_policy_document.lambda_permissions.json
  }
}

# IAM Policy for Lambda Function
data "aws_iam_policy_document" "lambda_permissions" {
  statement {
    actions   = ["ssm:GetParameters"]
    effect    = "Allow"
    resources = [aws_ssm_parameter.notify_test_api_key.arn]
  }

  statement {
    actions   = ["sns:Publish"]
    effect    = "Allow"
    resources = ["arn:aws:sns:${var.region}:${var.account_id}:${var.sns_topic}"]
  }
}