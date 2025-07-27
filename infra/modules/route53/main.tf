# Route53 Zone
resource "aws_route53_zone" "main" {
  count = var.create_hosted_zone ? 1 : 0
  name  = var.route53_zone_name
}

resource "aws_route53_record" "main" {
  zone_id = var.create_hosted_zone ? aws_route53_zone.main[0].id : var.route53_zone_id
  name    = var.route53_record_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# DNS validation records for ACM certificate
resource "aws_route53_record" "cert_validation" {
  for_each = var.enable_ssl ? {
    for dvo in var.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.create_hosted_zone ? aws_route53_zone.main[0].id : var.route53_zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "main" {
  count = var.enable_ssl ? 1 : 0

  certificate_arn         = var.certificate_arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  timeouts {
    create = "10m"
  }
}
