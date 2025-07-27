# 🔧 Configuration Guide

## Comprehensive Variabilization

This configuration is fully variabilized with **no hardcoded values**. All aspects can be customized:

- **Infrastructure**: VPC, subnets, security groups, load balancers
- **ECS Configuration**: Task definitions, services, scaling policies  
- **Health Checks**: Both ALB and container-level health checking
- **Monitoring**: CloudWatch settings and Container Insights
- **Security**: CIDR blocks, ports, protocols, and access controls

## Key Variables

| Variable | Description | Type | Example |
|----------|-------------|------|---------|
| `vpc_cidr` | CIDR block for VPC | string | `"10.0.0.0/16"` |
| `public_subnets` | Map of public subnet configurations | map(object) | See tfvars |
| `private_subnets` | Map of private subnet configurations | map(object) | See tfvars |
| `aws_region` | AWS region for deployment | string | `"us-east-1"` |
| `container_image` | Docker image for your application | string | `"nginx:latest"` |
| `container_port` | Port your application listens on | number | `8080` |
| `health_check_path` | Health check endpoint | string | `"/health"` |
| `app_name` | Name of the application | string | `"ecs-webapp"` |
| `environment` | Environment name | string | `"dev"` |

## ECS Configuration
| Variable | Description | Type | Example |
|----------|-------------|------|---------|
| `cpu` | CPU units (1024 = 1 vCPU) | number | `256` |
| `memory` | Memory in MiB | number | `512` |
| `desired_count` | Number of tasks to run | number | `2` |
| `min_capacity` | Minimum tasks for auto-scaling | number | `1` |
| `max_capacity` | Maximum tasks for auto-scaling | number | `10` |
| `launch_type` | ECS launch type | string | `"FARGATE"` |
| `network_mode` | Docker networking mode | string | `"awsvpc"` |
| `assign_public_ip` | Assign public IP to tasks | bool | `false` |

## Load Balancer Configuration
| Variable | Description | Type | Example |
|----------|-------------|------|---------|
| `alb_listener_port` | ALB listener port | number | `80` |
| `alb_listener_protocol` | ALB listener protocol | string | `"HTTP"` |
| `load_balancer_type` | Load balancer type | string | `"application"` |
| `enable_deletion_protection` | Enable deletion protection | bool | `false` |
| `alb_ingress_cidr_blocks` | CIDR blocks for ALB access | list(string) | `["0.0.0.0/0"]` |

## Health Check Configuration
| Variable | Description | Type | Example |
|----------|-------------|------|---------|
| `health_check_healthy_threshold` | Consecutive healthy checks required | number | `3` |
| `health_check_interval` | Health check interval (seconds) | number | `30` |
| `health_check_timeout` | Health check timeout (seconds) | number | `5` |
| `health_check_unhealthy_threshold` | Consecutive unhealthy checks required | number | `2` |
| `health_check_matcher` | HTTP status codes for healthy | string | `"200"` |

## Auto Scaling Configuration
| Variable | Description | Type | Example |
|----------|-------------|------|---------|
| `cpu_target_value` | CPU utilization target % | number | `70.0` |
| `memory_target_value` | Memory utilization target % | number | `80.0` |

## Container Health Check Configuration
| Variable | Description | Type | Example |
|----------|-------------|------|---------|
| `container_health_check_interval` | Container health check interval | number | `30` |
| `container_health_check_timeout` | Container health check timeout | number | `5` |
| `container_health_check_retries` | Container health check retries | number | `3` |
| `container_health_check_start_period` | Container health check start period | number | `60` |

## Monitoring Configuration
| Variable | Description | Type | Example |
|----------|-------------|------|---------|
| `log_retention_days` | CloudWatch log retention days | number | `7` |
| `enable_container_insights` | Enable Container Insights | bool | `true` |

## Sample Configuration

Edit `terraform.tfvars` and provide values for all required variables:

```hcl
vpc_cidr = "10.0.0.0/16"

public_subnets = {
  public1 = {
    cidr     = "10.0.1.0/24"
    az_index = 0
  }
  public2 = {
    cidr     = "10.0.2.0/24"
    az_index = 1
  }
}

private_subnets = {
  private1 = {
    cidr     = "10.0.11.0/24"
    az_index = 0
  }
  private2 = {
    cidr     = "10.0.12.0/24"
    az_index = 1
  }
}

aws_region         = "us-east-1"
container_port     = 5000
health_check_path  = "/health"
app_name          = "sohaib-portfolio"
environment       = "dev"

# ECS Configuration
container_image = "your-account.dkr.ecr.us-east-1.amazonaws.com/sohaib-portfolio:latest"
cpu            = 256
memory         = 512
desired_count  = 2
min_capacity   = 1
max_capacity   = 10
```

**Important**: All variables are **required** as no default values are provided. This ensures:
- **Explicit Configuration**: Every setting is intentionally chosen
- **Environment Consistency**: No accidental fallbacks to defaults
- **Production Safety**: Prevents deployment with unintended values
- **Infrastructure Documentation**: Configuration serves as documentation

Make sure to:
- Replace `container_image` with your actual Docker image URI
- Adjust CPU, memory, and scaling parameters for your workload
- Configure proper health check path for your application
- Set appropriate CIDR blocks for security
- Choose suitable auto-scaling thresholds for your traffic patterns