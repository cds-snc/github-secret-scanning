locals {
  api_cloudwatch_log_group = "/aws/lambda/${var.api_function_name}"
  error_logged_api         = "ErrorLoggedAPI"
  metric_namespace         = "GitHubSecretScanning"
  secret_detected_api      = "SecretDetectedAPI"
}
