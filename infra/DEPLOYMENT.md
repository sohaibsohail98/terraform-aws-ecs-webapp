# 🚀 Deployment Guide

## Prerequisites
- Terraform >= 1.0
- AWS CLI configured
- Docker for container builds

## Quick Start

### 1. Configure Variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit with your values
```

### 2. Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### 3. Access Application
```bash
terraform output alb_dns_name
```

## Key Configuration

### Network Settings
```hcl
vpc_cidr = "10.0.0.0/16"
public_subnets = {
  "1" = { cidr = "10.0.1.0/24", az_index = 0 }
  "2" = { cidr = "10.0.2.0/24", az_index = 1 }
}
private_subnets = {
  "1" = { cidr = "10.0.101.0/24", az_index = 0 }
  "2" = { cidr = "10.0.102.0/24", az_index = 1 }
}
```

### Application Settings
```hcl
app_name = "my-webapp"
environment = "production"
container_port = 5000
health_check_path = "/health"
```

### ECS Configuration
```hcl
cpu = 256
memory = 512
desired_count = 2
min_capacity = 1
max_capacity = 10
```

## Troubleshooting

### Common Issues
1. **Tasks not starting**: Check CloudWatch logs
2. **Health check failures**: Verify endpoint and timeouts
3. **502 errors**: Ensure port matching
4. **Auto scaling issues**: Check CloudWatch metrics

### Useful Commands
```bash
# View service status
aws ecs describe-services --cluster ecs-webapp-cluster --services <app-name>

# View logs
aws logs tail /ecs/<app-name> --follow

# Check target health
aws elbv2 describe-target-health --target-group-arn <arn>
```