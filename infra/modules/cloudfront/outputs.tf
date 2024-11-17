output "distribution_id" {
  value = aws_cloudfront_distribution.s3_distribution.id
}

output "distribution_arn" {
  value = aws_cloudfront_distribution.s3_distribution.arn
}

output "distribution_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "zone_id" {
  value = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
}

output "cloudfront_oai_arn" {
  value = aws_cloudfront_origin_access_identity.oai.iam_arn
}