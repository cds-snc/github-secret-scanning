variable "api_config" {
  description = "The API environment variables that are written to a .env read by the Lambda function."
  type        = string
  sensitive   = true
}
