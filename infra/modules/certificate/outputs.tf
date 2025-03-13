output "certificate_id" {
  value = aws_acm_certificate.cert.arn
}

output "domain_validation_options" {
  value = aws_acm_certificate.cert.domain_validation_options
}

output "validation_record_name" {
  value = tolist(aws_acm_certificate.cert.domain_validation_options).0.resource_record_name
}

output "validation_record_type" {
  value = tolist(aws_acm_certificate.cert.domain_validation_options).0.resource_record_type
}

output "validation_records" {
  value = tolist(aws_acm_certificate.cert.domain_validation_options).0.resource_record_value
}