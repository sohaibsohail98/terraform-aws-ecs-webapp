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

module "alb" {
  source = "./modules/alb"

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  container_port        = var.container_port
  health_check_path     = var.health_check_path
}

module "ecs" {
  source = "./ecs"

  # Core application variables
  app_name         = var.app_name
  environment      = var.environment
  aws_region       = var.aws_region
  container_port   = var.container_port

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
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  security_group_id   = module.security.ecs_security_group_id
  target_group_arn    = module.alb.target_group_arn
  listener_arn        = module.alb.listener_arn
}

