resource "aws_route53_zone" "github_secret_scanning" {
  name = var.domain

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}
