vpc_cidr = "10.0.0.0/16"

public_subnets = {
  public1 = {
    cidr     = "10.0.1.0/24"
    az_index = 0
  }
  public2 = {
    cidr     = "10.0.2.0/24"
    az_index = 1
  }
}

private_subnets = {
  private1 = {
    cidr     = "10.0.11.0/24"
    az_index = 0
  }
  private2 = {
    cidr     = "10.0.12.0/24"
    az_index = 1
  }
}

aws_region        = "us-east-1"
container_port    = 5000
health_check_path = "/health"
app_name          = "sohaib-portfolio"
environment       = "dev"

ecr_repository_name = "sohaibsohail/sohaib-portfolio"
image_tag           = "latest" # or any specific tag you want to use

# ECS Configuration
container_image = "" # Will be populated automatically from ECR
cpu             = 256
memory          = 512
desired_count   = 2
min_capacity    = 1
max_capacity    = 10

# Load Balancer Configuration
alb_listener_port          = 80
alb_listener_protocol      = "HTTP"
load_balancer_type         = "application"
enable_deletion_protection = false
alb_ingress_cidr_blocks    = ["0.0.0.0/0"]

# Health Check Configuration
health_check_healthy_threshold   = 3
health_check_interval            = 30
health_check_timeout             = 5
health_check_unhealthy_threshold = 2
health_check_matcher             = "200"

# Auto Scaling Configuration
cpu_target_value    = 70.0
memory_target_value = 80.0

# CloudWatch Configuration
log_retention_days = 7

# ECS Task Configuration
launch_type      = "FARGATE"
network_mode     = "awsvpc"
assign_public_ip = false

# Container Health Check Configuration
container_health_check_interval     = 30
container_health_check_timeout      = 5
container_health_check_retries      = 3
container_health_check_start_period = 60

# Security Configuration
enable_container_insights = true

route53_zone_name   = "sohaibsohail.com"
route53_record_name = "portfolio.sohaibsohail.com"
route53_zone_id     = "Z1234567890ABC" # Replace with your actual hosted zone ID

# SSL/HTTPS Configuration
enable_https         = true
enable_http_redirect = true