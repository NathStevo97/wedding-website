locals {
  www_domain = "www.${var.domain_name}"
  default_tags = {
    "Project"   = "Wedding Website"
    "ManagedBy" = "Terraform"
  }
}

module "s3" {
  source                  = "./modules/S3"
  domain_name             = var.domain_name
  cloudfront_arn          = module.cloudfront.distribution_arn
  cloudfront_oai          = module.cloudfront.cloudfront_oai_arn
  website_static_dir      = var.website_static_dir
  tags                    = local.default_tags
}

module "certificate" {
  source               = "./modules/certificate"
  domain_name = var.domain_name
}

data "aws_cloudfront_cache_policy" "CachingOptimized" {
  name = "Managed-CachingOptimized"
}

module "cloudfront" {
  source             = "./modules/cloudfront"
  domain_name        = var.domain_name
  acm_certificate_id = module.certificate.certificate_id
  bucket_domain      = module.s3.bucket_domain_name
  caching_policy_id  = data.aws_cloudfront_cache_policy.CachingOptimized.id
  site_password      = var.site_password
  tags               = local.default_tags
}

data "aws_cloudfront_cache_policy" "CachingDisabled" {
  name = "Managed-CachingDisabled"
}

module "route53" {
 source                     = "./modules/route53"
  domain_name               = var.domain_name
  hosted_zone_id            = var.hosted_zone_id
  cloudfront_zone_id        = module.cloudfront.zone_id
  cloudfront_distribution_id = module.cloudfront.distribution_domain_name
  domain_validation_options = module.certificate.domain_validation_options
}