variable "route53_zone_name" {
  description = "Route53 hosted zone name for the domain"
  type        = string
}

variable "route53_record_name" {
  description = "Route53 record name for the domain"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the ALB to create alias record for"
  type        = string
}

variable "alb_zone_id" {
  description = "Zone ID of the ALB to create alias record for"
  type        = string
}

