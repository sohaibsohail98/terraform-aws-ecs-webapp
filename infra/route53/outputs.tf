output "route53_zone_id" {
  value = aws_route53_zone.main.id
}

output "route53_record_name" {
  value = aws_route53_record.main.name
}

output "route53_record_type" {
  value = aws_route53_record.main.type
}
