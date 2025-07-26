# Core application variables
variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy the resources in."
  type        = string
}

variable "container_port" {
  description = "The port on which the container application runs"
  type        = number
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


# Auto Scaling Configuration
variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
}

variable "memory_target_value" {
  description = "Target memory utilization percentage for auto scaling"
  type        = number
}

variable "health_check_path" {
  description = "The path for ALB health check"
  type        = string
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


# ECS Cluster Configuration
variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for ECS cluster"
  type        = bool
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository for the application"
  type        = string
}

# Module integration variables
variable "vpc_id" {
  description = "ID of the VPC from vpc module"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs from vpc module"
  type        = list(string)
  default     = []
}

variable "security_group_id" {
  description = "Security group ID for ECS tasks from security module"
  type        = string
  default     = ""
}

variable "target_group_arn" {
  description = "ALB target group ARN from alb module"
  type        = string
  default     = ""
}

variable "listener_arn" {
  description = "ALB listener ARN from alb module"
  type        = string
  default     = ""
}