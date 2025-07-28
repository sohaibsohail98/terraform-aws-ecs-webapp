output "zone_id" {
  description = "Route53 hosted zone ID"
  value       = aws_route53_zone.main.id
}

output "zone_name_servers" {
  description = "Name servers for the hosted zone"
  value       = aws_route53_zone.main.name_servers
}

