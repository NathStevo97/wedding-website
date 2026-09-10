variable "domain_name" {
  description = "The S3 Bucket Name"
  type        = string
}

variable "cloudfront_arn" {
  description = "The Arn for the main Cloudfront Distribution"
  type        = string
}

variable "cloudfront_oai" {
  type = string
}

variable "website_static_dir" {
  type = string
}

variable "tags" {
  type = map(string)
}
