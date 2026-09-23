output "function_name" {
  description = "The name of the Lambda function"
  value       = module.api.function_name
}

output "function_url" {
  description = "The URL of the Lambda function"
  value       = aws_lambda_function_url.api.function_url
}

output "sentinel_forwarder_cognito_identity_pool_id" {
  description = "Cognito identity pool the Sentinel forwarder uses for its secretless v2 auth; the audience of the Azure federated credential"
  value       = aws_cognito_identity_pool.sentinel_forwarder_v2.id
}
