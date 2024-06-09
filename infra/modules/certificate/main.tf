provider "aws" {
  # Configuration options
  region = "eu-west-2"
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}

resource "aws_acm_certificate" "cert" {
  provider          = aws.acm_provider
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.acm_provider
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [var.cert_validation_fqdn]
}