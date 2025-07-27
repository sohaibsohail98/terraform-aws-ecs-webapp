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

variable "route53_zone_id" {
  description = "Existing Route53 hosted zone ID (if not creating new zone)"
  type        = string
  default     = null
}

variable "create_hosted_zone" {
  description = "Whether to create a new hosted zone or use existing one"
  type        = bool
  default     = false
}

variable "enable_ssl" {
  description = "Enable SSL certificate validation"
  type        = bool
  default     = false
}

variable "domain_validation_options" {
  description = "Domain validation options from ACM certificate"
  type        = any
  default     = []
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate to validate"
  type        = string
  default     = null
}

