output "cert_validation_fqdn" {
  value = aws_route53_record.my_cert_validation.fqdn
}