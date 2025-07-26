variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "alb_listener_port" {
  description = "Port for ALB listener"
  type        = number
  default     = 80
}

variable "alb_ingress_cidr_blocks" {
  description = "CIDR blocks for ALB ingress"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
}