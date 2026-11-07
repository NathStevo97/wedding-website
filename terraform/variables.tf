variable "domain_name" {
  description = "Optional custom domain; leave empty to use CloudFront's generated hostname"
  type        = string
  default     = ""
}

variable "hosted_zone_id" {
  description = "Optional Route 53 hosted zone ID for the custom domain"
  type        = string
  default     = ""
}

variable "site_password" {
  description = "Password for protecting the static website"
  type        = string
  sensitive   = true
}

variable "website_static_dir" {
  type        = string
  description = "Path to the root directory of website static content"
  default     = "../site"
}
