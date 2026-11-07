# Record for apex domain (non-www)
resource "aws_route53_record" "domain" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_distribution_id
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

# Record for www subdomain
resource "aws_route53_record" "www" {
  zone_id = var.hosted_zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.cloudfront_distribution_id
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}
