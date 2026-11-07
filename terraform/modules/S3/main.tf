resource "aws_s3_bucket" "this" {
  #checkov:skip=CKV2_AWS_62: Buckets in this project have no event notification consumer.
  #checkov:skip=CKV_AWS_18: The root configures site access logging; the log sink is intentionally not recursively logged.
  #checkov:skip=CKV_AWS_144: Cross-region replication is unnecessary for this personal static site.
  #checkov:skip=CKV_AWS_145: SSE-S3 is sufficient for these static-site buckets.
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  #checkov:skip=CKV_AWS_300: This configuration explicitly aborts uploads after seven days; Checkov misses the static rule alongside dynamic retention rules.
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    filter {
      prefix = ""
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  dynamic "rule" {
    for_each = var.expiration_days > 0 ? [var.expiration_days] : []

    content {
      id     = "expire-objects"
      status = "Enabled"

      filter {
        prefix = ""
      }

      expiration {
        days = rule.value
      }
    }
  }

  dynamic "rule" {
    for_each = var.noncurrent_expiration_days > 0 ? [var.noncurrent_expiration_days] : []

    content {
      id     = "expire-noncurrent-versions"
      status = "Enabled"

      filter {
        prefix = ""
      }

      noncurrent_version_expiration {
        noncurrent_days = rule.value
      }
    }
  }
}
