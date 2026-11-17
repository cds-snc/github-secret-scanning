resource "aws_ssm_parameter" "notify_doc_api_key" {
  name  = "notify_doc_api_key"
  type  = "SecureString"
  value = var.notify_doc_api_key

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
    ssc_cbrid  = "22DH"
  }
}

resource "aws_ssm_parameter" "tsuga_test_api_key" {
  name  = "tsuga_test_api_key"
  type  = "SecureString"
  value = var.tsuga_test_api_key

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
    ssc_cbrid  = "22DH"
  }
}
