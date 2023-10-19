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

# IAM Policy for Lambda Function
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