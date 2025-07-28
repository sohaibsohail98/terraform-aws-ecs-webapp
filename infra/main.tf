module "vpc" {
  source = "./modules/vpc"

  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "security" {
  source = "./modules/security"

  vpc_id                  = module.vpc.vpc_id
  container_port          = var.container_port
  alb_listener_port       = var.alb_listener_port
  alb_ingress_cidr_blocks = var.alb_ingress_cidr_blocks
}

module "acm" {
  count  = var.enable_https ? 1 : 0
  source = "./modules/acm"

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  app_name                  = var.app_name
  environment               = var.environment
}

module "alb" {
  source = "./modules/alb"

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  container_port        = var.container_port
  health_check_path     = var.health_check_path

  # ALB Configuration
  alb_listener_port          = var.alb_listener_port
  alb_listener_protocol      = var.alb_listener_protocol
  load_balancer_type         = var.load_balancer_type
  enable_deletion_protection = var.enable_deletion_protection

  # Health Check Configuration
  health_check_healthy_threshold   = var.health_check_healthy_threshold
  health_check_interval            = var.health_check_interval
  health_check_timeout             = var.health_check_timeout
  health_check_unhealthy_threshold = var.health_check_unhealthy_threshold
  health_check_matcher             = var.health_check_matcher

  # HTTP redirect configuration
  enable_http_redirect = var.enable_http_redirect
}

module "ecs" {
  source = "./modules/ecs"

  # Core application variables
  app_name          = var.app_name
  environment       = var.environment
  aws_region        = var.aws_region
  container_port    = var.container_port
  health_check_path = var.health_check_path

  # ECS-specific variables
  cpu                                 = var.cpu
  memory                              = var.memory
  desired_count                       = var.desired_count
  min_capacity                        = var.min_capacity
  max_capacity                        = var.max_capacity
  cpu_target_value                    = var.cpu_target_value
  memory_target_value                 = var.memory_target_value
  log_retention_days                  = var.log_retention_days
  launch_type                         = var.launch_type
  network_mode                        = var.network_mode
  assign_public_ip                    = var.assign_public_ip
  container_health_check_interval     = var.container_health_check_interval
  container_health_check_timeout      = var.container_health_check_timeout
  container_health_check_retries      = var.container_health_check_retries
  container_health_check_start_period = var.container_health_check_start_period
  enable_container_insights           = var.enable_container_insights
  ecr_repository_name                 = var.ecr_repository_name
  image_tag                           = var.image_tag

  # Module integration variables
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.security.ecs_security_group_id
  target_group_arn   = module.alb.target_group_arn
  listener_arn       = var.enable_https ? aws_lb_listener.https[0].arn : module.alb.listener_arn
}

module "route53" {
  source = "./modules/route53"

  route53_zone_name = var.route53_zone_name
}

# Certificate validation records
resource "aws_route53_record" "cert_validation" {
  for_each = var.enable_https ? {
    for dvo in module.acm[0].domain_validation_options : dvo.domain_name => {
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
  zone_id         = module.route53.zone_id

  depends_on = [module.route53, module.acm]
}

# Certificate validation
resource "aws_acm_certificate_validation" "main" {
  count = var.enable_https ? 1 : 0

  certificate_arn         = module.acm[0].certificate_arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  timeouts {
    create = "10m"
  }

  depends_on = [aws_route53_record.cert_validation]
}

# HTTPS Listener (created separately to avoid circular dependencies)
resource "aws_lb_listener" "https" {
  count = var.enable_https ? 1 : 0

  load_balancer_arn = module.alb.alb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate_validation.main[0].certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = module.alb.target_group_arn
  }

  depends_on = [aws_acm_certificate_validation.main]
}

# Route53 A record for ALB
resource "aws_route53_record" "main" {
  zone_id = module.route53.zone_id
  name    = var.route53_record_name
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }

  depends_on = [module.alb, module.route53]
}

