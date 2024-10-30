locals {
  www_domain = "www.${var.domain_name}"
}

module "s3" {
  source      = "./modules/S3"
  domain_name = var.domain_name
}

module "certificate" {
  source               = "./modules/certificate"
  domain_name          = local.www_domain
  cert_validation_fqdn = module.route53.cert_validation_fqdn
}

module "certificate_redirect" {
  source               = "./modules/certificate"
  domain_name          = var.domain_name
  cert_validation_fqdn = module.route53_redirect.cert_validation_fqdn
}

data "aws_cloudfront_cache_policy" "CachingOptimized" {
  name = "Managed-CachingOptimized"
}

module "cloudfront" {
  source             = "./modules/cloudfront"
  domain_name        = local.www_domain
  acm_certificate_id = module.certificate.certificate_id
  bucket_domain      = module.s3.bucket_domain_name
  caching_policy_id  = data.aws_cloudfront_cache_policy.CachingOptimized.id
  site_password      = var.site_password
}

data "aws_cloudfront_cache_policy" "CachingDisabled" {
  name = "Managed-CachingDisabled"
}

module "cloudfront_redirect" {
  source             = "./modules/cloudfront_redirect"
  domain_name        = var.domain_name
  acm_certificate_id = module.certificate_redirect.certificate_id
  bucket_domain      = module.s3.redirect_bucket_domain_name
  caching_policy_id  = data.aws_cloudfront_cache_policy.CachingDisabled.id
}

module "route53" {
  source                     = "./modules/route53"
  record_name                = "www"
  hosted_zone_id             = var.hosted_zone_id
  cloudfront_zone_id         = module.cloudfront.zone_id
  cloudfront_distribution_id = module.cloudfront.distribution_domain_name
  validation_record_name     = module.certificate.validation_record_name
  validation_record_type     = module.certificate.validation_record_type
  validation_records         = module.certificate.validation_records
}

module "route53_redirect" {
  source                     = "./modules/route53"
  record_name                = ""
  hosted_zone_id             = var.hosted_zone_id
  cloudfront_zone_id         = module.cloudfront_redirect.zone_id
  cloudfront_distribution_id = module.cloudfront_redirect.distribution_domain_name
  validation_record_name     = module.certificate_redirect.validation_record_name
  validation_record_type     = module.certificate_redirect.validation_record_type
  validation_records         = module.certificate_redirect.validation_records
}