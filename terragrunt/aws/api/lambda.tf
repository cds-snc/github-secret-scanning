module "api" {
  source    = "github.com/cds-snc/terraform-modules//lambda?ref=v9.5.1"
  name      = "${var.product_name}-api"
  ecr_arn   = aws_ecr_repository.api.arn
  image_uri = "${aws_ecr_repository.api.repository_url}:latest"

  memory                 = 1024
  timeout                = 120
  enable_lambda_insights = true

  environment_variables = {
    GITHUB_PUBLIC_KEYS_URL = "https://api.github.com/meta/public_keys/secret_scanning"
    LOG_LEVEL              = "WARNING"
  }

  policies = [
    data.aws_iam_policy_document.api_policies.json,
  ]

  billing_tag_value = var.billing_code
}

resource "aws_lambda_function_url" "api" {
  function_name      = module.api.function_name
  authorization_type = "NONE"
}
