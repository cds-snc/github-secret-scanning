variable "api_config" {
  description = "The API environment variables that are written to a .env read by the Lambda function."
  type        = string
  sensitive   = true
}

variable "log_analytics_workspace_id" {
  description = "The Sentinel workspace ID. Used by the Sentinel Forwarder to send the API logs to Sentinel."
  type        = string
  sensitive   = true
}

variable "log_analytics_workspace_key" {
  description = "The Sentinel workspace authentication key. Used by the Sentinel Forwarder to send the API logs to Sentinel."
  type        = string
  sensitive   = true
}
