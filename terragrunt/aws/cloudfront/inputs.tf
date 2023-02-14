variable "api_function_name" {
  description = "The name of the API lambda function"
  type        = string
}

variable "api_function_url" {
  description = "The URL of the API lambda function"
  type        = string
}

variable "cloudfront_header" {  
  description = "Header that gets added to all origin requests by CloudFront.  The API validates that this header is present and has the expected value."
  type = string
  sensitive = true
}

variable "enable_waf" {
  description = "(Optional) Should the WAF be enabled? Defaults to true."
  type        = bool
  default     = true
}

variable "hosted_zone_id" {
  description = "The hosted zone ID to create DNS records in"
  type        = string
}

