variable "domain_name" {
  description = "The domain name"
  type        = string
  default     = ""
}

variable "custom_domain_enabled" {
  description = "Whether to attach the custom domain and ACM certificate"
  type        = bool
  default     = false
}

variable "acm_certificate_id" {
  description = "ACM certificate ARN for the optional custom domain"
  type        = string
  default     = ""
}

variable "bucket_domain" {
  description = "Domain of the S3 bucket"
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

variable "tags" {
  type = map(string)
}
