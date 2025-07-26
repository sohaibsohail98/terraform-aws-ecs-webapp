# Route53 Zone
resource "aws_route53_zone" "main" {
  name = var.route53_zone_name
}

resource "aws_route53_record" "main" {
  zone_id = aws_route53_zone.main.id
  name    = var.route53_record_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
