resource "aws_ssm_parameter" "github_token" {
  name  = "${var.product_name}-github-token"
  type  = "SecureString"
  value = var.github_token

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}
