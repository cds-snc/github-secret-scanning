# IAM Role for Lambda Function
resource "aws_iam_role" "group_broadcast_alert_role" {
  name                = "group_broadcast_alert_role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# IAM Policy for Lambda Function to publish to SNS
resource "aws_iam_role_policy" "publish_to_sns" {
  name = "publish_to_sns"
  role = aws_iam_role.group_broadcast_alert_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:Publish"
        ]
        Effect   = "Allow"
        Sid      = "AllowSnsActions"
        Resource = "arn:aws:sns:${var.region}:${var.account_id}:${var.sns_topic}"
      }
    ]
  })
}

# IAM Policy for Lambda Function to get SSM Parameters
resource "aws_iam_role_policy" "ssm_get_parameters_policy" {
  name = "ssm_get_parameters_policy"
  role = aws_iam_role.group_broadcast_alert_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ssm:GetParameters"
        ]
        Sid      = "AllowSSMGetParameters",
        Effect   = "Allow",
        Resource = "arn:aws:ssm:${var.region}:${var.account_id}:parameter/notify_doc_api_key"
      }
    ]
  })
}
