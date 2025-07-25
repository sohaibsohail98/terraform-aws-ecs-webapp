variable vpc_id {
  description = "The VPC ID where the ECS cluster will be deployed."
  type        = string
}

variable subnets {
  description = "A map of subnet names to their CIDR blocks."
  type        = map(list(string))
}

variable aws_region {
  description = "The AWS region to deploy the resources in."
  type        = string
}