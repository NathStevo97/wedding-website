resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name          # e.g. chloeandnathan.com
  subject_alternative_names = ["*.${var.domain_name}"] # e.g. *.chloeandnathan.com
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Project"   = "Wedding Website"
    "ManagedBy" = "Terraform"
  }
}
