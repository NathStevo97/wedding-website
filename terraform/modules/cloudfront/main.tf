resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.domain_name != "" ? var.domain_name : "static site"}"
}

data "aws_cloudfront_response_headers_policy" "security" {
  name = "Managed-SecurityHeadersPolicy"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  #checkov:skip=CKV_AWS_374: Site visitors may be located anywhere.
  #checkov:skip=CKV_AWS_68: A WAF adds recurring cost for this personal site.
  #checkov:skip=CKV_AWS_86: S3 origin access logging is enabled; CloudFront access logs are not needed at this volume.
  #checkov:skip=CKV_AWS_174: Test mode uses CloudFront's default certificate; custom-domain mode pins TLS 1.2 or higher.
  #checkov:skip=CKV_AWS_310: A second origin adds cost and operational complexity beyond this site's availability needs.
  #checkov:skip=CKV2_AWS_47: WAF is intentionally omitted for this low-volume personal site.

  origin {
    domain_name = var.bucket_domain
    origin_id   = var.domain_name != "" ? var.domain_name : "static-site-origin"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  default_root_object = "index.html"
  http_version        = "http2and3"
  aliases             = var.custom_domain_enabled ? [var.domain_name, "www.${var.domain_name}"] : []

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 404
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 403
    response_code         = 404
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 503
    response_code         = 503
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.domain_name != "" ? var.domain_name : "static-site-origin"
    #cache_policy_id  = var.caching_policy_id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security.id

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = aws_lambda_function.auth_lambda.qualified_arn
    }

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      headers = ["Authorization"]
    }

    viewer_protocol_policy = var.custom_domain_enabled ? "redirect-to-https" : "allow-all"
    min_ttl                = 0
    default_ttl            = 360
    max_ttl                = 86400
    compress               = true
  }

  viewer_certificate {
    cloudfront_default_certificate = !var.custom_domain_enabled
    acm_certificate_arn            = var.custom_domain_enabled ? var.acm_certificate_id : null
    ssl_support_method             = var.custom_domain_enabled ? "sni-only" : null
    minimum_protocol_version       = var.custom_domain_enabled ? "TLSv1.2_2021" : null
  }

  tags = var.tags
}
