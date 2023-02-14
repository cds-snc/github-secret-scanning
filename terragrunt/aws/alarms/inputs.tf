variable "api_function_name" {
  description = "The name of the API function."
  type        = string
}

variable "slack_webhook_url" {
  description = "The URL of the Slack webhook."
  type        = string
  sensitive   = true
}
