resource "aws_route53_record" "domain" {
  zone_id = var.hosted_zone_id
  name    = var.record_name
  type    = "A"

  alias {
    name                   = var.cloudfront_distribution_id
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "my_cert_validation" {
  name    = var.validation_record_name
  type    = var.validation_record_type
  zone_id = var.hosted_zone_id
  records = [var.validation_records]
  ttl     = 60
}