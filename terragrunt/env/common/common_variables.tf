variable "account_id" {
  description = "The account ID to perform actions on"
  type        = string
}

variable "cbs_satellite_bucket_name" {
  description = "Name of the Cloud Based Sensor S3 satellite bucket"
  type        = string
}

variable "domain" {
  description = "Domain name of the secret scanning service"
  type        = string
}

variable "env" {
  description = "The current running environment"
  type        = string
}

variable "product_name" {
  description = "The name of the product you are deploying."
  type        = string
}

variable "region" {
  description = "The AWS region to deploy to"
  type        = string
}

variable "billing_code" {
  description = "The billing code to tag our resources with"
  type        = string
}
