# 🏗️ Infrastructure Architecture

## Module Overview

The infrastructure is organized into focused, reusable modules:

```
infra/
├── modules/
│   ├── vpc/              # Core networking
│   ├── alb/              # Load balancer
│   └── security/         # Security groups
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
┌─────────────┐
│     ALB     │ ← Depends on: VPC ID, subnet IDs, security group ID
└─────────────┘
       │
       ▼
┌─────────────┐
│     ECS     │ ← Depends on: all above outputs
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

## ALB Module
**Purpose**: Load balancing and traffic distribution
- Internet-facing Application Load Balancer
- Target group with health checks
- HTTP/HTTPS listener configuration

## ECS Module
**Purpose**: Container orchestration
- Fargate cluster with auto-scaling
- Service and task definitions
- ECR repository and IAM roles
- CloudWatch logging