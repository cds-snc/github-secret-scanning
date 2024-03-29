resource "aws_cloudfront_distribution" "api" {
  enabled     = true
  aliases     = [var.domain]
  price_class = "PriceClass_100"
  web_acl_id  = aws_wafv2_web_acl.api.arn

  origin {
    domain_name = split("/", var.api_function_url)[2]
    origin_id   = var.api_function_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_read_timeout    = 60
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "X-CloudFront-Header"
      value = var.cloudfront_header
    }
  }

  # Optimized caching for all GET/HEAD requests
  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      headers = [
        "GITHUB-PUBLIC-KEY-IDENTIFIER",
        "GITHUB-PUBLIC-KEY-SIGNATURE"
      ]
      cookies {
        forward = "none"
      }
    }

    target_origin_id           = var.api_function_name
    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers_api.id

    min_ttl     = 1
    default_ttl = 86400    # 24 hours
    max_ttl     = 31536000 # 365 days
    compress    = true
  }

  # Prevent caching of healthcheck calls
  ordered_cache_behavior {
    path_pattern    = "/healthcheck"
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    target_origin_id           = var.api_function_name
    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers_api.id

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
    compress    = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.api.certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

resource "aws_cloudfront_response_headers_policy" "security_headers_api" {
  name = "api-cloudfront-headers"

  security_headers_config {
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    content_type_options {
      override = true
    }
    content_security_policy {
      content_security_policy = "report-uri https://csp-report-to.security.cdssandbox.xyz/report; default-src 'none'; script-src 'self'; script-src-elem https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/ 'sha256-QOOQu4W1oxGqd2nbXbxiA1Di6OHQOLQD+o+G9oWL8YY='; connect-src 'self'; img-src 'self' https://fastapi.tiangolo.com/img/ data: 'unsafe-eval'; style-src 'self'; style-src-elem 'self' https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/; frame-ancestors 'self'; form-action 'self';"
      override                = false
    }
    referrer_policy {
      override        = true
      referrer_policy = "same-origin"
    }
    strict_transport_security {
      override                   = true
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = true
    }
    xss_protection {
      override   = true
      mode_block = true
      protection = true
    }
  }
}
