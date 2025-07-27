variable "vpc_cidr" {
  description = "The CIDR block for the VPC where the ECS cluster will be deployed."
  type        = string
}

variable "public_subnets" {
  description = "A map of public subnet configurations"
  type = map(object({
    cidr     = string
    az_index = number
  }))
}

variable "private_subnets" {
  description = "A map of private subnet configurations"
  type = map(object({
    cidr     = string
    az_index = number
  }))
}

variable "aws_region" {
  description = "The AWS region to deploy the resources in."
  type        = string
}

variable "container_port" {
  description = "The port on which the container application runs"
  type        = number
}

variable "health_check_path" {
  description = "The path for ALB health check"
  type        = string
}

variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

# ECS-specific variables
variable "container_image" {
  description = "Docker image for the ECS task (not used when using ECR)"
  type        = string
  default     = ""
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "cpu" {
  description = "CPU units for the ECS task (1024 = 1 vCPU)"
  type        = number
}

variable "memory" {
  description = "Memory for the ECS task in MiB"
  type        = number
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks for auto-scaling"
  type        = number
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks for auto-scaling"
  type        = number
}

# Load Balancer Configuration
variable "alb_listener_port" {
  description = "Port for the ALB listener"
  type        = number
}

variable "alb_listener_protocol" {
  description = "Protocol for the ALB listener"
  type        = string
}

# Health Check Configuration
variable "health_check_healthy_threshold" {
  description = "Number of consecutive health checks successes required"
  type        = number
}

variable "health_check_interval" {
  description = "Interval between health checks (seconds)"
  type        = number
}

variable "health_check_timeout" {
  description = "Health check timeout (seconds)"
  type        = number
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures required"
  type        = number
}

variable "health_check_matcher" {
  description = "HTTP status codes to consider healthy"
  type        = string
}

# Auto Scaling Configuration
variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
}

variable "memory_target_value" {
  description = "Target memory utilization percentage for auto scaling"
  type        = number
}

# CloudWatch Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
}

# ECS Configuration
variable "launch_type" {
  description = "ECS launch type (FARGATE or EC2)"
  type        = string
}

variable "network_mode" {
  description = "Docker networking mode for ECS tasks"
  type        = string
}

variable "assign_public_ip" {
  description = "Whether to assign public IP to ECS tasks"
  type        = bool
}

# Container Health Check Configuration
variable "container_health_check_interval" {
  description = "Container health check interval (seconds)"
  type        = number
}

variable "container_health_check_timeout" {
  description = "Container health check timeout (seconds)"
  type        = number
}

variable "container_health_check_retries" {
  description = "Container health check retry count"
  type        = number
}

variable "container_health_check_start_period" {
  description = "Container health check start period (seconds)"
  type        = number
}

# Load Balancer Configuration
variable "load_balancer_type" {
  description = "Type of load balancer (application, network, or gateway)"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for load balancer"
  type        = bool
}

# Security Configuration
variable "alb_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to access the ALB"
  type        = list(string)
}

# ECS Cluster Configuration
variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for ECS cluster"
  type        = bool
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository for the application"
  type        = string

}
variable "route53_zone_name" {
  description = "Route53 hosted zone name for the domain"
  type        = string
}

variable "route53_record_name" {
  description = "Route53 record name for the domain"
  type        = string
}


variable "enable_https" {
  description = "Enable HTTPS listener with SSL certificate"
  type        = bool
  default     = true
}

variable "enable_http_redirect" {
  description = "Enable HTTP to HTTPS redirect"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Primary domain name for ACM certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "Subject alternative names for ACM certificate"
  type        = list(string)
  default     = []
}