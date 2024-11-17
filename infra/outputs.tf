
output "cloudfront_distribution_id" {
  value = module.cloudfront.distribution_id
}

output "cloudfront_distribution_domain" {
  value = module.cloudfront.distribution_domain_name
}

output "redirect_cloudfront_distribution_id" {
  value = module.cloudfront_redirect.distribution_id
}

output "redirect_cloudfront_distribution_domain" {
  value = module.cloudfront_redirect.distribution_domain_name
}

output "bucket_name" {
  value = module.s3.bucket_id
}

output "redirect_bucket_name" {
  value = module.s3.redirect_bucket_id
}

output "bucket_domain" {
  value = module.s3.bucket_domain_name
}

output "redirect_bucket_domain" {
  value = module.s3.redirect_bucket_domain_name
}

