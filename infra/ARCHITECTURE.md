# 🏗️ Infrastructure Architecture

## Module Overview

The infrastructure is organized into focused, reusable modules:

```
infra/
├── modules/
│   ├── vpc/              # Core networking
│   ├── alb/              # Load balancer with HTTPS
│   ├── security/         # Security groups
│   └── acm/              # SSL certificates
├── route53/              # DNS management & cert validation
├── ecs/                  # Container orchestration
└── main.tf              # Module orchestration
```

## Module Dependencies

```
┌─────────────┐
│     VPC     │ ← Foundation: networking infrastructure
└─────────────┘
       │
       ▼
┌─────────────┐
│  Security   │ ← Depends on: VPC ID
└─────────────┘
       │
       ▼
┌─────────────┐      ┌─────────────┐
│     ACM     │      │     ALB     │ ← Depends on: VPC, Security
└─────────────┘      └─────────────┘
       │                     │
       └──────┬──────────────┘
              ▼
      ┌─────────────┐
      │   Route53   │ ← Depends on: ACM (validation), ALB (DNS)
      └─────────────┘
              │
              ▼
      ┌─────────────┐
      │     ECS     │ ← Depends on: ALB target group
      └─────────────┘
```

## VPC Module
**Purpose**: Core networking foundation
- Multi-AZ VPC with public/private subnets
- Internet and NAT gateways
- Route tables and associations

## Security Module
**Purpose**: Network security controls
- ALB security group (internet → ALB)
- ECS security group (ALB → containers only)
- Least-privilege access model

## ACM Module
**Purpose**: SSL certificate management
- Automated SSL certificate creation
- DNS validation method
- Certificate lifecycle management

## ALB Module
**Purpose**: Load balancing and traffic distribution
- Internet-facing Application Load Balancer
- Target group with health checks
- HTTPS listener (port 443) with SSL termination
- HTTP redirect (port 80 → 443) for security

## Route53 Module
**Purpose**: DNS management and certificate validation
- DNS record management (A record → ALB)
- SSL certificate validation via DNS
- Support for existing or new hosted zones
- Single source of truth for all DNS operations

## ECS Module
**Purpose**: Container orchestration
- Fargate cluster with auto-scaling
- Service and task definitions
- ECR repository and IAM roles
- CloudWatch logging

## Security Features
- **HTTPS-Only**: Automatic HTTP to HTTPS redirect
- **SSL Termination**: ACM certificates with auto-renewal
- **DNS Validation**: Automated certificate validation
- **Security Groups**: Least-privilege network access