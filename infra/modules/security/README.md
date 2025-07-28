# Security Module

Creates security groups for ALB and ECS tasks with least privilege access patterns.

## Security Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Internet                                │
└─────────────────────┬───────────────────────────────────────┘
                      │ HTTP/HTTPS (80/443)
┌─────────────────────▼───────────────────────────────────────┐
│               ALB Security Group                             │
│  ├── Inbound: 80, 443 from 0.0.0.0/0                       │
│  └── Outbound: container_port to ECS Security Group         │
└─────────────────────┬───────────────────────────────────────┘
                      │ container_port
┌─────────────────────▼───────────────────────────────────────┐
│               ECS Security Group                             │
│  ├── Inbound: container_port from ALB Security Group        │
│  └── Outbound: 443 to 0.0.0.0/0 (HTTPS for API calls)      │
└─────────────────────────────────────────────────────────────┘
```

## Resources Created

- **ALB Security Group**: Controls access to Application Load Balancer
- **ECS Security Group**: Controls access to ECS tasks

## Inputs

| Variable | Type | Description |
|----------|------|-------------|
| `vpc_id` | string | ID of the VPC |
| `alb_listener_port` | number | Port for ALB listener |
| `alb_ingress_cidr_blocks` | list(string) | CIDR blocks for ALB ingress |
| `container_port` | number | Port on which container listens |

## Outputs

| Output | Description |
|--------|-------------|
| `alb_security_group_id` | Security group ID for ALB |
| `ecs_security_group_id` | Security group ID for ECS tasks |

## Security Rules

### ALB Security Group Rules

**Inbound Rules**:
- **HTTP**: Port 80 from internet (0.0.0.0/0)
- **HTTPS**: Port 443 from internet (0.0.0.0/0)

**Outbound Rules**:
- **To ECS**: Container port to ECS security group
- **All Traffic**: All outbound traffic allowed (default)

### ECS Security Group Rules

**Inbound Rules**:
- **From ALB**: Container port from ALB security group only

**Outbound Rules**:
- **HTTPS**: Port 443 to internet (for API calls, package downloads)
- **All Traffic**: All outbound traffic allowed (default)

## Security Best Practices

### Principle of Least Privilege
- ALB only accepts HTTP/HTTPS from internet
- ECS only accepts traffic from ALB on application port
- No direct internet access to ECS tasks

### Network Segmentation
- Security groups act as virtual firewalls
- Traffic flow: Internet → ALB → ECS
- ECS tasks in private subnets for additional protection

### Controlled Outbound Access
- ECS tasks can make outbound HTTPS calls
- No inbound internet access to ECS tasks
- ALB acts as single entry point

## Example Usage

```hcl
module "security" {
  source = "./modules/security"

  vpc_id                  = module.vpc.vpc_id
  container_port          = 5000
  alb_listener_port       = 80
  alb_ingress_cidr_blocks = ["0.0.0.0/0"]
}
```

## Dependencies

- **VPC Module**: Requires VPC ID for security group creation

## Security Considerations

- **Internet Exposure**: Only ALB is internet-facing
- **Application Isolation**: ECS tasks are isolated in private subnets
- **Controlled Access**: All traffic flows through load balancer
- **Monitoring**: Security group rules are logged in VPC Flow Logs

## Common Patterns

### Development Environment
```hcl
alb_ingress_cidr_blocks = ["0.0.0.0/0"]  # Open to internet
```

### Corporate Environment
```hcl
alb_ingress_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12"]  # Corporate networks only
```

### Staging/Testing
```hcl
alb_ingress_cidr_blocks = ["203.0.113.0/24"]  # Specific IP ranges
```