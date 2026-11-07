

data "aws_caller_identity" "current" {}

module "site_bucket" {
  source                     = "./modules/S3"
  bucket_name                = local.site_bucket_name
  noncurrent_expiration_days = 90
  tags                       = local.default_tags
}

module "logging_bucket" {
  source          = "./modules/S3"
  bucket_name     = "${local.site_bucket_name}-logs"
  expiration_days = 30
  tags            = local.default_tags
}

resource "terraform_data" "sync_site" {
  triggers_replace = [local.site_content_hash, module.site_bucket.bucket_id]

  provisioner "local-exec" {
    command = "aws s3 sync '${var.website_static_dir}' 's3://${module.site_bucket.bucket_id}'"
  }

  depends_on = [module.site_bucket]
}

resource "aws_s3_bucket_logging" "site_bucket_logging" {
  bucket        = module.site_bucket.bucket_id
  target_bucket = module.logging_bucket.bucket_id
  target_prefix = "log/"
}

resource "aws_s3_bucket_policy" "logging_delivery" {
  bucket = module.logging_bucket.bucket_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowS3ServerAccessLogDelivery"
      Effect    = "Allow"
      Principal = { Service = "logging.s3.amazonaws.com" }
      Action    = "s3:PutObject"
      Resource  = "${module.logging_bucket.bucket_arn}/log/*"
      Condition = {
        ArnLike = {
          "aws:SourceArn" = [module.site_bucket.bucket_arn]
        }
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
      }
    }]
  })
}

resource "aws_s3_bucket_policy" "static_site_cloudfront" {
  bucket = module.site_bucket.bucket_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowCloudFrontOAIRead"
      Effect    = "Allow"
      Principal = { AWS = module.cloudfront.cloudfront_oai_arn }
      Action    = "s3:GetObject"
      Resource  = "${module.site_bucket.bucket_arn}/*"
    }]
  })
}

module "certificate" {
  count       = local.custom_domain_enabled ? 1 : 0
  source      = "./modules/certificate"
  domain_name = var.domain_name
}

data "aws_cloudfront_cache_policy" "CachingOptimized" {
  name = "Managed-CachingOptimized"
}

module "cloudfront" {
  source                = "./modules/cloudfront"
  domain_name           = var.domain_name
  custom_domain_enabled = local.custom_domain_enabled
  acm_certificate_id    = local.custom_domain_enabled ? aws_acm_certificate_validation.cert_validation[0].certificate_arn : ""
  bucket_domain         = module.site_bucket.bucket_domain_name
  caching_policy_id     = data.aws_cloudfront_cache_policy.CachingOptimized.id
  site_password         = var.site_password
  tags                  = local.default_tags

  depends_on = [terraform_data.sync_site]
}

resource "aws_route53_record" "cert_validation" {
  count = local.custom_domain_enabled ? 1 : 0

  allow_overwrite = true
  name            = tolist(module.certificate[0].domain_validation_options)[0].resource_record_name
  records         = [tolist(module.certificate[0].domain_validation_options)[0].resource_record_value]
  ttl             = 60
  type            = tolist(module.certificate[0].domain_validation_options)[0].resource_record_type
  zone_id         = var.hosted_zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  count           = local.custom_domain_enabled ? 1 : 0
  certificate_arn = module.certificate[0].certificate_id

  validation_record_fqdns = aws_route53_record.cert_validation[*].fqdn
}

module "route53" {
  count                      = local.custom_domain_enabled ? 1 : 0
  source                     = "./modules/route53"
  domain_name                = var.domain_name
  hosted_zone_id             = var.hosted_zone_id
  cloudfront_zone_id         = module.cloudfront.zone_id
  cloudfront_distribution_id = module.cloudfront.distribution_domain_name
}
