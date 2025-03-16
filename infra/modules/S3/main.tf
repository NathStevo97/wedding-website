locals {
  www_domain = "www.${var.domain_name}"
  mime_types = {
    ".html" = "text/html",
    ".css"  = "text/css",
    ".js"   = "application/javascript",
    ".png"  = "image/png",
    ".jpg"  = "image/jpeg",
    ".jpeg" = "image/jpeg",
    ".gif"  = "image/gif",
    ".svg"  = "image/svg+xml",
    ".ico"  = "image/x-icon"
  }
}

resource "aws_s3_bucket" "static_website_bucket" {
  bucket        = local.www_domain
  force_destroy = true
  tags          = var.tags

  provisioner "local-exec" {
    command = "aws s3 sync ../site s3://${local.www_domain}"
  }
}

resource "aws_s3_bucket_acl" "static_website_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.static_website_ownership]

  bucket = aws_s3_bucket.static_website_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "static_website_ownership" {
  depends_on = [aws_s3_bucket_public_access_block.static_website_public_access]

  bucket = aws_s3_bucket.static_website_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "static_website_public_access" {
  bucket = aws_s3_bucket.static_website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.static_website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAI"
        Effect = "Allow"
        Principal = {
          AWS = var.cloudfront_oai
        }
        Action = "s3:GetObject"
        Resource = [
          "${aws_s3_bucket.static_website_bucket.arn}",
          "${aws_s3_bucket.static_website_bucket.arn}/*"
        ]
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.static_website_public_access]
}

resource "aws_s3_bucket_versioning" "static_website_versioning" {
  bucket = aws_s3_bucket.static_website_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Logging Infrastructure

resource "aws_s3_bucket" "logging_bucket" {
  bucket = "${local.www_domain}-logs"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "logging_public_access" {
  bucket = aws_s3_bucket.logging_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket     = aws_s3_bucket.logging_bucket.id
  depends_on = [aws_s3_bucket_ownership_controls.static_website_ownership]
  acl        = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "logging_config" {
  bucket = aws_s3_bucket.static_website_bucket.id

  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_versioning" "logging_versioning" {
  bucket = aws_s3_bucket.logging_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}