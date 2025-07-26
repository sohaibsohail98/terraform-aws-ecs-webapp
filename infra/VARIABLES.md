# 📝 Variable Reference

## Core Variables

| Variable | Description | Type | Example |
|----------|-------------|------|---------|
| `vpc_cidr` | CIDR block for VPC | string | `"10.0.0.0/16"` |
| `aws_region` | AWS region | string | `"us-east-1"` |
| `app_name` | Application name | string | `"ecs-webapp"` |
| `environment` | Environment name | string | `"prod"` |

## Network Configuration

| Variable | Description | Type |
|----------|-------------|------|
| `public_subnets` | Public subnet configurations | map(object) |
| `private_subnets` | Private subnet configurations | map(object) |

Example:
```hcl
public_subnets = {
  "1" = { cidr = "10.0.1.0/24", az_index = 0 }
  "2" = { cidr = "10.0.2.0/24", az_index = 1 }
}
```

## ECS Configuration

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `cpu` | CPU units (1024 = 1 vCPU) | number | - |
| `memory` | Memory in MiB | number | - |
| `desired_count` | Number of tasks | number | - |
| `min_capacity` | Min tasks for scaling | number | - |
| `max_capacity` | Max tasks for scaling | number | - |
| `launch_type` | ECS launch type | string | - |

## Load Balancer

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `container_port` | Container port | number | - |
| `health_check_path` | Health check endpoint | string | - |
| `alb_ingress_cidr_blocks` | Allowed CIDR blocks | list(string) | - |

## Auto Scaling

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `cpu_target_value` | CPU utilization target % | number | - |
| `memory_target_value` | Memory utilization target % | number | - |

## Monitoring

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `log_retention_days` | CloudWatch log retention | number | - |
| `enable_container_insights` | Enable Container Insights | bool | - |

## Container Health Checks

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `container_health_check_interval` | Check interval (seconds) | number | - |
| `container_health_check_timeout` | Check timeout (seconds) | number | - |
| `container_health_check_retries` | Retry count | number | - |
| `container_health_check_start_period` | Start period (seconds) | number | - |

**Note**: All variables are required (no defaults) to ensure explicit configuration.