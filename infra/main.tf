/* resource "aws_s3_bucket" "state_bucket" {
  bucket = "nathan-chloe-wedding-bucket-tfstate"

  tags = {
    Name        = "nathan-chloe-wedding-bucket-tfstate"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
} */

resource "aws_s3_bucket" "site_bucket" {
  bucket = "nathan-chloe-wedding-bucket-site-content"

  tags = {
    Name        = "nathan-chloe-wedding-bucket-site-content"
  }
}