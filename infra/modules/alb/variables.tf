variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "load_balancer_type" {
  description = "Type of load balancer"
  type        = string
  default     = "application"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive health checks successes required"
  type        = number
  default     = 2
}

variable "health_check_interval" {
  description = "Approximate amount of time between health checks"
  type        = number
  default     = 30
}

variable "health_check_matcher" {
  description = "Response codes to use when checking for a healthy response"
  type        = string
  default     = "200"
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "health_check_timeout" {
  description = "Amount of time to wait when receiving a response"
  type        = number
  default     = 5
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures required"
  type        = number
  default     = 2
}

variable "alb_listener_port" {
  description = "Port for ALB listener"
  type        = number
  default     = 80
}

variable "alb_listener_protocol" {
  description = "Protocol for ALB listener"
  type        = string
  default     = "HTTP"
}