locals {
  api_cloudwatch_log_group = "/aws/lambda/${var.api_function_name}"
  error_logged_api         = "ErrorLoggedAPI"
  metric_namespace         = "GitHubSecretScanning"
  secret_detected_api      = "SecretDetectedAPI"

  secret_detected_metric = [
    "Secret detected",
  ]
  secret_detected_metric_skip = [
    "dsp-testing",
    "example.com",
    "gcntfy-github-test-revoked",
    "gcntfy-my_test_key",
    "gcntfy-test",
    "cds-snc/notification-documentation",
    "dry-runs-test",
    "00000000-0000-0000-0000-000000000000-00000000-0000-0000-0000-000000000000",
    "11111111-1111-1111-1111-111111111111-11111111-1111-1111-1111-111111111111",
  ]
  secret_detected_metric_pattern = "[(w1=\"*${join("*\" || w1=\"*", local.secret_detected_metric)}*\") && w1!=\"*${join("*\" && w1!=\"*", local.secret_detected_metric_skip)}*\"]"
}
