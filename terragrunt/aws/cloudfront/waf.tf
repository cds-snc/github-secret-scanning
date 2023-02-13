resource "aws_wafv2_web_acl" "api" {
  provider = aws.us-east-1

  name        = var.product_name
  description = "WAF for GitHub secret alert API"
  scope       = "CLOUDFRONT"

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }

  default_action {
    allow {}
  }

  rule {
    name     = "APIInvalidPath"
    priority = 1

    action {
      dynamic "block" {
        for_each = var.enable_waf == true ? [""] : []
        content {
        }
      }

      dynamic "count" {
        for_each = var.enable_waf == false ? [""] : []
        content {
        }
      }
    }

    statement {
      not_statement {
        statement {
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.valid_uri_paths.arn
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 1
              type     = "COMPRESS_WHITE_SPACE"
            }
            text_transformation {
              priority = 2
              type     = "LOWERCASE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "APIInvalidPaths"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 10

    override_action {
      dynamic "none" {
        for_each = var.enable_waf == true ? [""] : []
        content {
        }
      }

      dynamic "count" {
        for_each = var.enable_waf == false ? [""] : []
        content {
        }
      }
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "APIRateLimit"
    priority = 20

    action {
      dynamic "block" {
        for_each = var.enable_waf == true ? [""] : []
        content {
        }
      }

      dynamic "count" {
        for_each = var.enable_waf == false ? [""] : []
        content {
        }
      }
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "APIRateLimit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 30

    override_action {
      dynamic "none" {
        for_each = var.enable_waf == true ? [""] : []
        content {
        }
      }

      dynamic "count" {
        for_each = var.enable_waf == false ? [""] : []
        content {
        }
      }
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 40

    override_action {
      dynamic "none" {
        for_each = var.enable_waf == true ? [""] : []
        content {
        }
      }

      dynamic "count" {
        for_each = var.enable_waf == false ? [""] : []
        content {
        }
      }
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesLinuxRuleSet"
    priority = 50

    override_action {
      dynamic "none" {
        for_each = var.enable_waf == true ? [""] : []
        content {
        }
      }

      dynamic "count" {
        for_each = var.enable_waf == false ? [""] : []
        content {
        }
      }
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesLinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "api"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_regex_pattern_set" "valid_uri_paths" {
  provider    = aws.us-east-1
  name        = "valid-api-paths"
  description = "Regex to match the API valid paths"
  scope       = "CLOUDFRONT"

  # ops
  regular_expression {
    regex_string = "^/(healthcheck|version|docs|openapi.json|.well-known/security.txt)$"
  }

  # alerts
  regular_expression {
    regex_string = "^/alert$"
  }

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

resource "aws_kinesis_firehose_delivery_stream" "api" {
  provider = aws.us-east-1

  name        = "aws-waf-logs-${var.product_name}"
  destination = "extended_s3"

  server_side_encryption {
    enabled = true
  }

  extended_s3_configuration {
    role_arn           = aws_iam_role.waf_log_role.arn
    prefix             = "waf_acl_logs/AWSLogs/${var.account_id}/"
    bucket_arn         = local.cbs_satellite_bucket_arn
    compression_format = "GZIP"

    cloudwatch_logging_options {
      enabled = false
    }
  }

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "api" {
  provider                = aws.us-east-1
  log_destination_configs = [aws_kinesis_firehose_delivery_stream.api.arn]
  resource_arn            = aws_wafv2_web_acl.api.arn
}
