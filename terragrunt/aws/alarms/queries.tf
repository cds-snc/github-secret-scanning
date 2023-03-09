resource "aws_cloudwatch_query_definition" "api_errors" {
  name = "Errors API"

  log_group_names = [
    local.api_cloudwatch_log_group
  ]

  query_string = <<-QUERY
    fields @timestamp, @message, @logStream
    | filter @message like /(?i)ERROR/
    | sort @timestamp desc
    | limit 20
  QUERY
}

resource "aws_cloudwatch_query_definition" "api_secret_detected" {
  name = "Secret detected API"

  log_group_names = [
    local.api_cloudwatch_log_group
  ]

  query_string = <<-QUERY
    fields @timestamp, @message, @logStream
    | filter @message like /Secret detected/
    | sort @timestamp desc
    | limit 20
  QUERY
}
