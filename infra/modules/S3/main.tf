locals {
  www_domain = "www.${var.domain_name}"
}

resource "aws_s3_bucket" "static_website_bucket" {
  bucket = local.www_domain
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "static_website_bucket_config" {
  bucket = aws_s3_bucket.static_website_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_acl" "static_website_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.static_website_ownership]

  bucket = aws_s3_bucket.static_website_bucket.id
  acl    = "public-read"
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

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}



data "aws_iam_policy_document" "public_read_policy_document" {
  statement {
    sid    = "PublicReadGetObject"
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${local.www_domain}/*"]
  }
}

resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.static_website_bucket.id
  policy = data.aws_iam_policy_document.public_read_policy_document.json
  depends_on = [aws_s3_bucket_public_access_block.static_website_public_access]
}

# Redirect Bucket

resource "aws_s3_bucket" "redirect_bucket" {
  bucket = var.domain_name
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "redirect_bucket_config" {
  bucket = aws_s3_bucket.redirect_bucket.id

  redirect_all_requests_to {
    host_name = local.www_domain
    protocol = "https"
  }
}

resource "aws_s3_bucket_acl" "redirect_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.redirect_bucket_ownership]

  bucket = aws_s3_bucket.redirect_bucket.id
  acl    = "public-read"
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

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Upload Objects

resource "null_resource" "upload_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 sync ../site s3://${aws_s3_bucket.static_website_bucket.id}"
  }
}

resource "null_resource" "upload_to_s3_redirect" {
  provisioner "local-exec" {
    command = "aws s3 sync ../site s3://${aws_s3_bucket.redirect_bucket.id}"
  }
}