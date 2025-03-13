
output "cloudfront_distribution_id" {
  value = module.cloudfront.distribution_id
}

output "cloudfront_distribution_domain" {
  value = module.cloudfront.distribution_domain_name
}

output "bucket_name" {
  value = module.s3.bucket_id
}

output "bucket_domain" {
  value = module.s3.bucket_domain_name
}
