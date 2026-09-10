variable "hosted_zone_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "cloudfront_distribution_id" {
  type = string
}

variable "cloudfront_zone_id" {
  type = string
}

variable "domain_validation_options" {
  type = set(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_type  = string
    resource_record_value = string
  }))
  description = "Domain validation options for ACM certificate"
}
