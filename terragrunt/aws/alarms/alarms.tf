resource "aws_cloudwatch_log_metric_filter" "api_error" {
  name           = local.error_logged_api
  pattern        = "?ERROR ?Error ?error ?failed"
  log_group_name = local.api_cloudwatch_log_group

  metric_transformation {
    name      = local.error_logged_api
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "api_error" {
  alarm_name          = "GitHub secret scanning: error"
  alarm_description   = "Error logged by the API lambda function."
  comparison_operator = "GreaterThanOrEqualToThreshold"

  metric_name        = aws_cloudwatch_log_metric_filter.api_error.metric_transformation[0].name
  namespace          = aws_cloudwatch_log_metric_filter.api_error.metric_transformation[0].namespace
  period             = "60"
  evaluation_periods = "1"
  statistic          = "Sum"
  threshold          = "1"
  treat_missing_data = "notBreaching"

  alarm_actions = [local.sns_topic_arn]
  ok_actions    = [local.sns_topic_arn]
}

resource "aws_cloudwatch_log_metric_filter" "api_secret_detected" {
  name           = local.secret_detected_api
  pattern        = "\"Secret detected\" -revoked"
  log_group_name = local.api_cloudwatch_log_group

  metric_transformation {
    name      = local.secret_detected_api
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "api_secret_detected" {
  alarm_name          = "GitHub secret scanning: secret detected"
  alarm_description   = "GitHub alert that a secret has been found in a repo."
  comparison_operator = "GreaterThanOrEqualToThreshold"

  metric_name        = aws_cloudwatch_log_metric_filter.api_secret_detected.metric_transformation[0].name
  namespace          = aws_cloudwatch_log_metric_filter.api_secret_detected.metric_transformation[0].namespace
  period             = "60"
  evaluation_periods = "1"
  statistic          = "Sum"
  threshold          = "1"
  treat_missing_data = "notBreaching"

  alarm_actions = [local.sns_topic_arn]
}
