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
  tags = {
    "Project"   = "Wedding Website"
    "ManagedBy" = "Terraform"
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

resource "aws_s3_object" "site_files" {
  for_each = fileset(var.website_static_dir, "**")

  bucket       = aws_s3_bucket.static_website_bucket.id
  key          = each.value
  source       = "${var.website_static_dir}/${each.key}"
  source_hash  = filemd5("${var.website_static_dir}/${each.key}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.key), null)
  tags = {
    "Project"   = "Wedding Website"
    "ManagedBy" = "Terraform"
  }
}

# Redirect Bucket

resource "aws_s3_bucket" "redirect_bucket" {
  bucket        = var.domain_name
  force_destroy = true
  tags = {
    "Project"   = "Wedding Website"
    "ManagedBy" = "Terraform"
  }
}

resource "aws_s3_bucket_acl" "redirect_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.redirect_bucket_ownership]

  bucket = aws_s3_bucket.redirect_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "redirect_bucket_ownership" {
  depends_on = [aws_s3_bucket_public_access_block.redirect_bucket_public_access]

  bucket = aws_s3_bucket.redirect_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "redirect_bucket_public_access" {
  bucket = aws_s3_bucket.redirect_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "redirect_site_versioning" {
  bucket = aws_s3_bucket.redirect_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "redirect_site_files" {
  for_each = fileset(var.website_static_dir, "**")

  bucket       = aws_s3_bucket.redirect_bucket.id
  key          = each.value
  source       = "${var.website_static_dir}/${each.key}"
  source_hash  = filemd5("${var.website_static_dir}/${each.key}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.key), null)
  tags = {
    "Project"   = "Wedding Website"
    "ManagedBy" = "Terraform"
  }
}

/* resource "aws_s3_bucket_cors_configuration" "redirect_bucket" {
  bucket = aws_s3_bucket.redirect_bucket.id

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["https://${var.domain_name}"] # Replace with your domain in production
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }
} */