output "route53_zone_id" {
  value = var.create_hosted_zone ? aws_route53_zone.main[0].id : var.route53_zone_id
}

output "zone_id" {
  description = "Route53 hosted zone ID"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].id : var.route53_zone_id
}

output "route53_record_name" {
  value = aws_route53_record.main.name
}

output "route53_record_type" {
  value = aws_route53_record.main.type
}

output "validated_certificate_arn" {
  description = "ARN of the validated ACM certificate"
  value       = var.enable_ssl ? aws_acm_certificate_validation.main[0].certificate_arn : null
}
