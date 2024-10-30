variable "domain_name" {
  description = "The domain name"
  type        = string
}

variable "bucket_domain" {
  description = "Domain of the S3 bucket"
  type        = string
}

variable "acm_certificate_id" {
  description = "The SSL Certificate Id"
  type        = string
}

variable "caching_policy_id" {
  description = "The Caching Policy Id"
  type        = string
}

variable "site_password" {
  description = "Password for protecting the static website"
  type        = string
  sensitive   = true
}