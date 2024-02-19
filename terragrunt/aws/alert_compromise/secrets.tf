resource "aws_ssm_parameter" "notify_test_api_key" {
  name  = "notify_test_api_key"
  type  = "SecureString"
  value = var.notify_test_api_key

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}