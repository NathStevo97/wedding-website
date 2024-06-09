resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "S3 Origin Access Control - ${var.domain_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {

  origin {
    domain_name              = var.bucket_domain
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
    origin_id                = var.domain_name
  }

  enabled             = true
  default_root_object = "index.html"
  http_version        = "http2and3"
  aliases             = [var.domain_name]

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 404
    response_page_path    = "/404.html"
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

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.acm_certificate_id
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}