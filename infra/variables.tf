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