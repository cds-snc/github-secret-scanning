# Local variables to get the api lambda function group name and arn
locals {
  target_log_group_name = "/aws/lambda/${var.api_function_name}"
  target_log_group_arn  = "arn:aws:logs:${var.region}:${var.account_id}:log-group:${local.target_log_group_name}"
}

# This data block creates an archive file of the broadcast_alert.py script
# to be used in the AWS Lambda function.
data "archive_file" "broadcast_alert" {
  type        = "zip"
  source_file = "${path.module}/functions/broadcast_alert.py"
  output_path = "/tmp/broadcast_alert.py.zip"
}

# Lambda function that will broadcast the alert to the SNS topic
resource "aws_lambda_function" "broadcast_alert" {
  function_name = var.function_name
  description   = "Notify other teams that their API keys have been compromised."
  role          = aws_iam_role.group_broadcast_alert_role.arn
  handler       = "broadcast_alert.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60

  filename         = data.archive_file.broadcast_alert.output_path
  source_code_hash = filebase64sha256(data.archive_file.broadcast_alert.output_path)

  tracing_config {
    mode = "PassThrough"
  }
  environment {
    variables = {
      sns_topic_arn = "arn:aws:sns:${var.region}:${var.account_id}:${var.sns_topic}"
      subject       = var.subject_message
    }
  }
  depends_on = [
    aws_iam_role.group_broadcast_alert_role
  ]
}

# Permission that allows the Cloudwatch service to execute the Lambda function
resource "aws_lambda_permission" "broadcast_alert_lambda_permission" {
  action        = "lambda:InvokeFunction"
  principal     = "logs.ca-central-1.amazonaws.com"
  function_name = aws_lambda_function.broadcast_alert.arn
  source_arn    = "${local.target_log_group_arn}:*"
}

# Subscription filter that is tied to the Cloudwatch log group of the api function and parsses the logs with a 
# filter pattern of "Secret detected" and sends it to the Lambda function
resource "aws_cloudwatch_log_subscription_filter" "broadcast_alert_lambda_logfilter" {
  name            = "broadcast_alert_lambda_logfilter"
  depends_on      = ["aws_lambda_permission.broadcast_alert_lambda_permission"]
  log_group_name  = local.target_log_group_name
  filter_pattern  = "Secret detected"
  destination_arn = aws_lambda_function.broadcast_alert.arn
}