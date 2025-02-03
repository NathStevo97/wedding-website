variable "region" {
  description = "The Region"
  type        = string
}

variable "domain_name" {
  description = "The S3 Bucket Name/Domain Name"
  type        = string
}

variable "hosted_zone_id" {
  description = "The Hosted Zone Id of the domain"
  type        = string
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