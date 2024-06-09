output "bucket_domain_name" {
  value = aws_s3_bucket.static_website_bucket.bucket_regional_domain_name
}


output "redirect_bucket_domain_name" {
  value = aws_s3_bucket_website_configuration.redirect_bucket_config.website_endpoint
}
