resource "aws_s3_bucket" "logging_bucket" {
  bucket        = "${local.www_domain}-logs"
  force_destroy = true
  tags = var.tags
}

resource "aws_s3_bucket_logging" "logging" {
  bucket = aws_s3_bucket.static_website_bucket.id

  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "logs/${local.www_domain}/"
}

resource "aws_s3_bucket_logging" "redirect_logging" {
  bucket = aws_s3_bucket.redirect_bucket.id

  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "logs/${var.domain_name}/"
}