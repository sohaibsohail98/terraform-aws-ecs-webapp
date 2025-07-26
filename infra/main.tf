module "vpc" {
  source = "./modules/vpc"

  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "security" {
  source = "./modules/security"

  vpc_id         = module.vpc.vpc_id
  container_port = var.container_port
}

module "acm" {
  count  = var.enable_https ? 1 : 0
  source = "./modules/acm"

  domain_name = var.route53_record_name
  app_name    = var.app_name
  environment = var.environment
}

module "alb" {
  source = "./modules/alb"

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  container_port        = var.container_port
  health_check_path     = var.health_check_path

  # SSL/HTTPS configuration
  enable_https         = var.enable_https
  enable_http_redirect = var.enable_http_redirect
  certificate_arn      = var.enable_https ? module.acm[0].certificate_arn : null
}

module "ecs" {
  source = "./ecs"

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

  # Module integration variables
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.security.ecs_security_group_id
  target_group_arn   = module.alb.target_group_arn
  listener_arn       = module.alb.listener_arn
}

module "route53" {
  source = "./route53"

  route53_zone_name   = var.route53_zone_name
  route53_record_name = var.route53_record_name
  route53_zone_id     = var.route53_zone_id
  create_hosted_zone  = false # Use existing hosted zone
  alb_dns_name        = module.alb.alb_dns_name
  alb_zone_id         = module.alb.alb_zone_id

  # SSL certificate validation
  enable_ssl                = var.enable_https
  domain_validation_options = var.enable_https ? module.acm[0].domain_validation_options : []
  certificate_arn           = var.enable_https ? module.acm[0].certificate_arn : null

  depends_on = [module.acm, module.alb]
}

