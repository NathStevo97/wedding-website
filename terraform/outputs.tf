
output "cloudfront_distribution_id" {
  value       = module.cloudfront.distribution_id
  description = "The ID of the CloudFront distribution created for the S3 bucket."
}

output "cloudfront_distribution_domain" {
  value       = module.cloudfront.distribution_domain_name
  description = "The domain name of the CloudFront distribution."
}

output "bucket_name" {
  value       = module.s3.bucket_id
  description = "The name of the S3 bucket created for static website hosting."
}

output "bucket_domain" {
  value       = module.s3.bucket_domain_name
  description = "The domain name of the S3 bucket for static website hosting."
}
