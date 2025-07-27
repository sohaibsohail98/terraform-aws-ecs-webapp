variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnets" {
  description = "Map of public subnets with CIDR and AZ index"
  type = map(object({
    cidr     = string
    az_index = number
  }))
}

variable "private_subnets" {
  description = "Map of private subnets with CIDR and AZ index"
  type = map(object({
    cidr     = string
    az_index = number
  }))
}