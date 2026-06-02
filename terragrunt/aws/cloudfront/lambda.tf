# Restrict invocation of the API Lambda function to this CloudFront distribution.
# These permissions live in the CloudFront module (rather than the API module) to
# avoid a circular Terragrunt dependency: the CloudFront distribution depends on
# the API function URL/name, and these permissions depend on the distribution ARN.
resource "aws_lambda_permission" "api_invoke_function_url" {
  statement_id           = "AllowInvokeFunctionUrl"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = var.api_function_name
  function_url_auth_type = "AWS_IAM"
  principal              = "cloudfront.amazonaws.com"
  source_arn             = aws_cloudfront_distribution.api.arn
}

resource "aws_lambda_permission" "api_invoke_function" {
  statement_id  = "AllowInvokeFunction"
  action        = "lambda:InvokeFunction"
  function_name = var.api_function_name
  principal     = "cloudfront.amazonaws.com"
  source_arn    = aws_cloudfront_distribution.api.arn
}
