provider "aws" {
  # Configuration options
  region = "eu-west-2"
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}

resource "aws_acm_certificate" "cert" {
  provider                  = aws.acm_provider
  domain_name              = var.domain_name  # e.g. chloeandnathan.com
  subject_alternative_names = ["*.${var.domain_name}"]  # e.g. *.chloeandnathan.com
  validation_method        = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Project"   = "Wedding Website"
    "ManagedBy" = "Terraform"
  }
}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.acm_provider
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_acm_certificate.cert.domain_validation_options : record.resource_record_name]
}