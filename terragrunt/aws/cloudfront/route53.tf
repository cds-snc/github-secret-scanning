resource "aws_route53_record" "api_A" {
  zone_id = var.hosted_zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.api.domain_name
    zone_id                = aws_cloudfront_distribution.api.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_health_check" "api" {
  fqdn              = aws_route53_record.api_A.fqdn
  port              = 443
  type              = "HTTPS"
  resource_path     = "/healthcheck"
  failure_threshold = "5"
  request_interval  = "30"
  regions           = ["us-east-1", "us-west-1", "us-west-2"]

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}
