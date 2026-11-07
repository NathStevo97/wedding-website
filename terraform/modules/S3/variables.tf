variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "force_destroy" {
  description = "Allow Terraform to delete all objects when destroying the bucket"
  type        = bool
  default     = true
}

variable "expiration_days" {
  description = "Optional object expiration in days; zero disables expiration"
  type        = number
  default     = 0
}

variable "noncurrent_expiration_days" {
  description = "Optional noncurrent object-version expiration in days; zero disables expiration"
  type        = number
  default     = 0
}

variable "tags" {
  type = map(string)
}
