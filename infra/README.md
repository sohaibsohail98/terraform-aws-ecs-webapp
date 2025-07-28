# 🏗️ Terraform Infrastructure

Production-ready, modular Terraform infrastructure for deploying scalable ECS Fargate applications on AWS with SSL/HTTPS support and comprehensive monitoring.

## 🎯 Architecture Overview

This infrastructure creates a highly available, secure, and scalable web application environment using AWS best practices:

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet Gateway                        │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                 Application Load Balancer                     │
│                 (Public Subnets)                              │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                  ECS Fargate Tasks                           │
│                 (Private Subnets)                            │
│              Auto-scaling enabled                            │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Module Structure

### Core Modules

| Module | Purpose | Resources Created |
|--------|---------|-------------------|
| **vpc** | Network foundation | VPC, subnets, NAT gateways, route tables, IGW |
| **security** | Access control | Security groups for ALB and ECS |
| **alb** | Load balancing | Application Load Balancer, target groups, HTTP listener |
| **ecs** | Container orchestration | ECS cluster, service, task definitions, auto-scaling |
| **acm** | SSL certificates | ACM certificate for HTTPS |
| **route53** | DNS management | Hosted zone creation |

### Resource Associations (main.tf)

The main configuration handles cross-module dependencies to avoid circular references:

- **Certificate Validation**: DNS records and certificate validation
- **HTTPS Listener**: SSL-enabled listener for ALB
- **DNS Records**: A records pointing to load balancer
- **Service Dependencies**: Proper resource ordering

## 🔧 Recent Fixes & Improvements

### ✅ Circular Dependency Resolution

**Problem Solved**: Eliminated circular dependencies between Route53, ACM, and ALB modules.

**Solution Applied**:
- Modules only create their core resources
- Cross-module associations moved to `main.tf`
- Clean dependency chain: Route53 → ACM → Certificate Validation → HTTPS Listener

### ✅ Certificate Validation Issues

**Problem Solved**: Certificate validation timeouts and HTTPS listener failures.

**Solution Applied**:
- Proper DNS validation workflow
- Certificate validation completes before ALB uses it
- Target group associations wait for validated listeners

### ✅ Code Quality Improvements

- Removed all default values from module variables
- Eliminated conditional complexity
- Simplified Route53 logic (always creates hosted zone)
- Clean, predictable module behavior

## 🚀 Deployment Guide

### Prerequisites

1. **AWS CLI configured** with appropriate permissions
2. **Terraform >= 1.0** installed
3. **Docker** for container builds
4. **Domain registered** (for HTTPS setup)

### Quick Deploy

```bash
# Navigate to infrastructure directory
cd infra/

# Initialize Terraform
terraform init

# Review and customize variables
cp terraform.tfvars.example terraform.tfvars
vi terraform.tfvars

# Plan deployment
terraform plan

# Deploy infrastructure
terraform apply
```

### Environment Variables

Required variables in `terraform.tfvars`:

```hcl
# Core Configuration
app_name     = "your-app-name"
environment  = "dev"
aws_region   = "us-east-1"

# Networking
vpc_cidr = "10.0.0.0/16"

# SSL/HTTPS (optional)
enable_https              = true
domain_name               = "yourdomain.com"
route53_zone_name         = "yourdomain.com"
route53_record_name       = "app.yourdomain.com"

# Application
container_port = 5000
health_check_path = "/health"
```

## 📊 Infrastructure Features

### 🔒 Security

- **Network Isolation**: ECS tasks run in private subnets
- **Security Groups**: Least privilege access (HTTP/HTTPS from internet to ALB, ALB to ECS only)
- **IAM Roles**: Minimal permissions for ECS tasks and execution
- **Encryption**: State files and application data

### 📈 Scalability

- **Auto Scaling**: CPU and memory-based scaling policies
- **Multi-AZ**: Resources distributed across availability zones
- **Load Balancing**: Application Load Balancer with health checks
- **Container Orchestration**: ECS Fargate for serverless containers

### 📊 Monitoring

- **CloudWatch Logs**: Centralized application logging
- **Container Insights**: Enhanced ECS metrics and monitoring
- **Health Checks**: Application and infrastructure health monitoring
- **Metrics**: CPU, memory, network, and custom application metrics

### 🌐 Networking

- **VPC**: Isolated network environment
- **Public Subnets**: For load balancer and NAT gateways
- **Private Subnets**: For ECS tasks (secure)
- **Route Tables**: Proper routing for public/private traffic

## 🔍 Troubleshooting

### Common Issues

1. **Certificate Validation Timeout**
   - Ensure domain NS records point to Route53 name servers
   - Check domain ownership and DNS propagation

2. **ECS Service Startup Issues**
   - Verify container image exists in ECR
   - Check ECS task execution role permissions
   - Review CloudWatch logs for application errors

3. **Load Balancer Health Check Failures**
   - Confirm application responds on correct port
   - Verify health check path returns 200 status
   - Check security group rules

### Debug Commands

```bash
# Check deployment status
terraform plan -detailed-exitcode

# Validate configuration
terraform validate

# View current state
terraform show

# Debug specific module
terraform plan -target=module.ecs

# View outputs
terraform output
```

## 📖 Module Documentation

Each module contains its own documentation:

- `modules/vpc/README.md` - VPC and networking setup
- `modules/alb/README.md` - Load balancer configuration  
- `modules/ecs/README.md` - Container orchestration
- `modules/security/README.md` - Security groups and access control
- `modules/acm/README.md` - SSL certificate management
- `modules/route53/README.md` - DNS and domain setup

## 🔄 Upgrade Path

To upgrade from previous versions:

1. **Backup Current State**: `terraform state pull > backup.tfstate`
2. **Review Changes**: `terraform plan` to see what will change
3. **Apply Gradually**: Use `-target` for sensitive resources
4. **Verify Functionality**: Test application after each major change

## 📝 Best Practices

### Module Development
- Single responsibility per module
- No default values in module variables
- Clear input/output interfaces
- Comprehensive documentation

### Deployment
- Use remote state backend (S3 + DynamoDB)
- Enable state file encryption
- Plan before apply in production
- Use workspaces for multiple environments

### Security
- Regular security audits
- Least privilege access
- Encrypt sensitive data
- Monitor access patterns

---

**Note**: This infrastructure demonstrates production-ready patterns and is suitable for enterprise environments. All modules follow AWS Well-Architected Framework principles.