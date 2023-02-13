resource "aws_ssm_parameter" "api_config" {
  name  = "${var.product_name}-config"
  type  = "SecureString"
  value = var.github_token

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}
