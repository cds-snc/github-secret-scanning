variable "sns_topic" {
  description = "The name of the sns topic to send alerts to"
  type        = string
  default     = "internal-sre-alert"
}

variable "subject_message" {
  description = "The subject of the message to be sent"
  type        = string
  default     = "Notify API key has been leaked"
}

variable "function_name" {
  description = "Name of the Lambda function to parse the message and send a sns message."
  type        = string
  default     = "broadcast_alert"

  validation {
    condition     = length(var.function_name) < 65
    error_message = "The function name must be between 1 and 64 characters in length."
  }

  validation {
    condition     = can(regex("^[A-Za-z][\\w-]{0,63}$", var.function_name))
    error_message = "The function name must only contain alphanumeric, underscore and hyphen characters."
  }
}

variable "api_function_name" {
  description = "The name of the api lambda function"
  type        = string
}