variable "hosted_zone_id" {
  description = "The Hosted Zone Id of the domain"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "The Cloudfront distribution id"
  type        = string
}

variable "validation_record_name" {
  description = "The validation record name"
  type        = string
}

variable "validation_record_type" {
  description = "The validation record type"
  type        = string
}

variable "validation_records" {
  description = "The validation records"
  type        = string
}

variable "cloudfront_zone_id" {
  description = "The Zone Id of cloudfront"
  type        = string
}

variable "record_name" {
  description = "The DNS Record Name"
  type        = string
}