
output "cloudfront_distribution_id" {
  value = module.cloudfront.distribution_id
}

output "bucket_name" {
  value = module.s3.bucket_id
}

output "redirect_bucket_name" {
  value = module.s3.redirect_bucket_id
}