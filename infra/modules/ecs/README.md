# ECS Module

Creates an ECS Fargate cluster with auto-scaling, monitoring, and ECR integration for containerized application deployment.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     ECS Cluster                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                 ECS Service                           │  │
│  │  ├── Task Definition (CPU/Memory)                    │  │
│  │  ├── Container Definition (Image/Ports/Env)          │  │
│  │  ├── Auto Scaling (CPU/Memory based)                 │  │
│  │  └── Load Balancer Integration                       │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────┐
│                    Support Services                          │
│  ├── CloudWatch Log Group (/ecs/app-name)                   │
│  ├── IAM Execution Role (ECR/CloudWatch permissions)        │
│  ├── IAM Task Role (Application permissions)                │
│  └── ECR Repository (Container images)                      │
└─────────────────────────────────────────────────────────────┘
```

## Resources Created

### Core ECS Resources
- **ECS Cluster**: Fargate cluster with Container Insights
- **ECS Service**: Manages desired count and deployments
- **ECS Task Definition**: Container specifications and resource allocation
- **Auto Scaling Target**: Manages service scaling
- **Auto Scaling Policies**: CPU and memory-based scaling

### Supporting Resources
- **IAM Execution Role**: Permissions for ECS agent (ECR, CloudWatch)
- **IAM Task Role**: Permissions for application containers
- **CloudWatch Log Group**: Centralized logging
- **ECR Repository**: Container image storage
- **ECR Lifecycle Policy**: Automatic image cleanup
- **ECR Repository Policy**: Access control

## Inputs

| Variable | Type | Description |
|----------|------|-------------|
| `app_name` | string | Name of the application |
| `environment` | string | Environment (dev, staging, prod) |
| `aws_region` | string | AWS region for deployment |
| `container_port` | number | Port on which container listens |
| `cpu` | number | CPU units (256, 512, 1024, etc.) |
| `memory` | number | Memory in MiB (512, 1024, 2048, etc.) |
| `desired_count` | number | Desired number of tasks |
| `min_capacity` | number | Minimum tasks for auto-scaling |
| `max_capacity` | number | Maximum tasks for auto-scaling |
| `cpu_target_value` | number | Target CPU utilization % |
| `memory_target_value` | number | Target memory utilization % |
| `vpc_id` | string | VPC ID from vpc module |
| `private_subnet_ids` | list(string) | Private subnet IDs |
| `security_group_id` | string | ECS security group ID |
| `target_group_arn` | string | ALB target group ARN |
| `listener_arn` | string | ALB listener ARN |

## Outputs

| Output | Description |
|--------|-------------|
| `cluster_name` | ECS cluster name |
| `service_name` | ECS service name |
| `task_definition_arn` | Task definition ARN |
| `ecr_repository_url` | ECR repository URL |
| `log_group_name` | CloudWatch log group name |

## Container Configuration

### Task Definition Features
- **Fargate Launch Type**: Serverless container execution
- **Network Mode**: awsvpc for VPC integration
- **Resource Allocation**: Configurable CPU and memory
- **Health Checks**: Container-level health monitoring
- **Logging**: Integrated CloudWatch logging

### Container Environment
- **Environment Variables**: Flask secret key, environment
- **Port Mappings**: Container port configuration
- **Health Check**: curl-based endpoint monitoring
- **Resource Limits**: CPU and memory constraints

## Auto Scaling Configuration

### CPU-Based Scaling
- **Metric**: ECSServiceAverageCPUUtilization
- **Target Value**: Configurable (default: 70%)
- **Scale Out**: When CPU > target for sustained period
- **Scale In**: When CPU < target for sustained period

### Memory-Based Scaling
- **Metric**: ECSServiceAverageMemoryUtilization
- **Target Value**: Configurable (default: 80%)
- **Scale Out**: When memory > target for sustained period
- **Scale In**: When memory < target for sustained period

## ECR Integration

### Repository Features
- **Image Storage**: Secure container image registry
- **Lifecycle Policy**: Automatic cleanup of old images
- **Repository Policy**: Access control and permissions
- **Image Scanning**: Security vulnerability scanning

### Lifecycle Policy
```json
{
  "rules": [
    {
      "rulePriority": 1,
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 7
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
```

## Monitoring & Logging

### CloudWatch Integration
- **Log Group**: `/ecs/{app_name}`
- **Log Retention**: Configurable retention period
- **Container Insights**: Enhanced metrics and monitoring
- **Application Logs**: Stdout/stderr capture

### Health Monitoring
- **ALB Health Checks**: Load balancer level monitoring
- **Container Health Checks**: Application endpoint monitoring
- **Service Health**: ECS service task monitoring

## Security Features

- **Network Isolation**: Tasks run in private subnets
- **IAM Roles**: Separate execution and task roles
- **Least Privilege**: Minimal permissions for each role
- **VPC Integration**: Full VPC security group support

## Example Usage

```hcl
module "ecs" {
  source = "./modules/ecs"

  # Core application variables
  app_name          = "my-app"
  environment       = "prod"
  aws_region        = "us-east-1"
  container_port    = 5000
  health_check_path = "/health"

  # ECS configuration
  cpu           = 512
  memory        = 1024
  desired_count = 2
  min_capacity  = 1
  max_capacity  = 10

  # Auto scaling
  cpu_target_value    = 70.0
  memory_target_value = 80.0

  # Module integration
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.security.ecs_security_group_id
  target_group_arn   = module.alb.target_group_arn
  listener_arn       = module.alb.listener_arn
}
```

## Dependencies

- **VPC Module**: Requires VPC and private subnets
- **Security Module**: Requires ECS security group
- **ALB Module**: Requires target group and listener ARNs

## Best Practices

- Uses Fargate for serverless container management
- Implements auto-scaling for cost optimization
- Comprehensive logging and monitoring
- Security-first approach with IAM roles
- ECR integration for secure image management
- Health checks at multiple levels