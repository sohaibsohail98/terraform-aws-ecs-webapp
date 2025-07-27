# Route53 Zone - Always create the hosted zone
resource "aws_route53_zone" "main" {
  name = var.route53_zone_name

  tags = {
    Name = "${var.route53_zone_name}-hosted-zone"
  }
}

