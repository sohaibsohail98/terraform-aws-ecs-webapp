# ALB Module

Creates an Application Load Balancer with target groups and HTTP listener for distributing traffic to ECS tasks.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Internet                                │
└─────────────────────┬───────────────────────────────────────┘
                      │ HTTP/HTTPS
┌─────────────────────▼───────────────────────────────────────┐
│              Application Load Balancer                       │
│                 (Public Subnets)                             │
│  ├── HTTP Listener (Port 80)                                │
│  └── Target Group (Health Checks)                           │
└─────────────────────┬───────────────────────────────────────┘
                      │ Forward Traffic
┌─────────────────────▼───────────────────────────────────────┐
│                  ECS Tasks                                   │
│               (Private Subnets)                              │
└─────────────────────────────────────────────────────────────┘
```

## Resources Created

- **Application Load Balancer**: Internet-facing load balancer
- **Target Group**: Routes traffic to ECS tasks with health checks
- **HTTP Listener**: Handles incoming HTTP traffic (port 80)

**Note**: HTTPS listener is created in `main.tf` to avoid circular dependencies with certificate validation.

## Inputs

| Variable | Type | Description |
|----------|------|-------------|
| `vpc_id` | string | ID of the VPC |
| `public_subnet_ids` | list(string) | List of public subnet IDs |
| `alb_security_group_id` | string | Security group ID for ALB |
| `container_port` | number | Port on which container listens |
| `health_check_path` | string | Health check endpoint path |
| `alb_listener_port` | number | Port for ALB listener |
| `alb_listener_protocol` | string | Protocol for ALB listener |
| `load_balancer_type` | string | Type of load balancer |
| `enable_deletion_protection` | bool | Enable deletion protection |
| `enable_http_redirect` | bool | Enable HTTP to HTTPS redirect |
| `health_check_*` | various | Health check configuration |

## Outputs

| Output | Description |
|--------|-------------|
| `alb_dns_name` | DNS name of the load balancer |
| `alb_zone_id` | Zone ID of the load balancer |
| `alb_arn` | ARN of the load balancer |
| `target_group_arn` | ARN of the target group |
| `http_listener_arn` | ARN of the HTTP listener |
| `listener_arn` | ARN of the primary listener |

## Health Check Configuration

The target group includes comprehensive health checks:

- **Health Check Path**: Configurable endpoint (e.g., `/health`)
- **Health Check Interval**: How often to check (default: 30s)
- **Healthy Threshold**: Consecutive successes needed (default: 3)
- **Unhealthy Threshold**: Consecutive failures before unhealthy (default: 2)
- **Timeout**: Time to wait for response (default: 5s)
- **Matcher**: HTTP response codes considered healthy (default: 200)

## Security Features

- **Internet-facing**: Accepts traffic from internet via security groups
- **Target Type IP**: Routes to ECS task IPs directly
- **Health Monitoring**: Automatic health checks and failover
- **Security Group Integration**: Works with security module

## HTTP Redirect Support

When `enable_http_redirect` is true:
- HTTP traffic (port 80) redirects to HTTPS (port 443)
- Uses 301 permanent redirect
- Maintains original request path and query parameters

## Example Usage

```hcl
module "alb" {
  source = "./modules/alb"

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  container_port        = 5000
  health_check_path     = "/health"
  
  # ALB Configuration
  alb_listener_port          = 80
  alb_listener_protocol      = "HTTP"
  load_balancer_type         = "application"
  enable_deletion_protection = false
  
  # Health Check Configuration
  health_check_healthy_threshold   = 3
  health_check_interval            = 30
  health_check_timeout             = 5
  health_check_unhealthy_threshold = 2
  health_check_matcher             = "200"

  # HTTP redirect configuration
  enable_http_redirect = true
}
```

## Dependencies

- **VPC Module**: Requires VPC and public subnets
- **Security Module**: Requires ALB security group
- **Main.tf**: HTTPS listener created separately to avoid circular dependencies

## Best Practices

- Uses application load balancer for Layer 7 routing
- Configurable health checks for application monitoring
- Supports both HTTP-only and HTTP+HTTPS configurations
- Enables deletion protection for production environments
- Multi-AZ deployment for high availability