# terraform/provider.tf
# Provider and terraform configuration

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "ecs-webapp-terraform-state-sohaib"
    key            = "terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
    use_lockfile = true
  }
}

# Provider configuration
provider "aws" {
  region = var.aws_region
}
