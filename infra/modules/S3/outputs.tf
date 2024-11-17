output "bucket_domain_name" {
  value = aws_s3_bucket.static_website_bucket.bucket_regional_domain_name
}

output "bucket_id" {
  value = aws_s3_bucket.static_website_bucket.id
}

output "redirect_bucket_domain_name" {
  value = aws_s3_bucket.redirect_bucket.bucket_regional_domain_name
}

output "redirect_bucket_id" {
  value = aws_s3_bucket.redirect_bucket.id
}