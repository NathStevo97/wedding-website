resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.domain_name}"
}


resource "aws_cloudfront_distribution" "s3_distribution" {

  origin {
    domain_name = var.bucket_domain
    origin_id   = var.domain_name
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  default_root_object = "index.html"
  http_version        = "http2and3"
  aliases             = [var.domain_name]

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
    target_origin_id = var.domain_name
    cache_policy_id  = var.caching_policy_id

    /* forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    } */

    /* lambda_function_association {
      event_type   = "viewer-request"
      include_body = false
      lambda_arn   = "arn:aws:lambda:us-east-1:862772511843:function:test-python-site-auth:1"
    } */

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 360
    max_ttl                = 86400
    compress               = true
  }

  # Dynamic block for static asset cache behaviors
  dynamic "ordered_cache_behavior" {
    for_each = ["css", "js", "jpg", "jpeg", "png"]
    content {
      path_pattern     = "*/*.${ordered_cache_behavior.value}"
      allowed_methods  = ["GET", "HEAD", "OPTIONS"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = var.domain_name
      cache_policy_id  = var.caching_policy_id

      /* forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    } */

      viewer_protocol_policy = "redirect-to-https"
      min_ttl                = 0
      default_ttl            = 86400    # 24 hours
      max_ttl                = 31536000 # 1 year
      compress               = true
    }
  }


  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.acm_certificate_id
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  tags = {
    "Project"   = "Wedding Website"
    "ManagedBy" = "Terraform"
  }
}