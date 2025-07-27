# 🔒 Security Features & Best Practices

## Security Architecture

This infrastructure implements security best practices across all layers:

### Network Security
- **Network Isolation**: ECS tasks run in private subnets with no direct internet access
- **Security Groups**: Least privilege access with port restrictions
- **Multi-layer Defense**: ALB → ECS communication only through security groups
- **VPC Flow Logs**: Network traffic monitoring and analysis

### Access Control
- **IAM Roles**: Minimal permissions following AWS best practices
- **Least Privilege**: Each role has only necessary permissions
- **No Long-lived Credentials**: Uses IAM roles for service authentication
- **Resource-based Policies**: Fine-grained access control

### Data Protection
- **Encryption in Transit**: HTTPS/TLS for all external communication
- **Encryption at Rest**: S3 state files encrypted with AES-256
- **Secrets Management**: Environment variables for sensitive data
- **State Locking**: Prevents concurrent modifications and corruption

## Detailed Security Controls

### 1. Network Security Groups

#### ALB Security Group
```hcl
resource "aws_security_group" "alb" {
  ingress {
    from_port   = 80  # or 443 for HTTPS
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Configurable
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

**Security Benefits**:
- Only allows HTTP/HTTPS traffic
- Configurable source CIDR blocks
- Explicit egress rules

#### ECS Tasks Security Group
```hcl
resource "aws_security_group" "ecs_tasks" {
  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]  # Only from ALB
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

**Security Benefits**:
- Traffic only from ALB security group
- No direct external access to containers
- Granular port control

### 2. IAM Security Model

#### ECS Task Execution Role
```hcl
resource "aws_iam_role" "ecs_task_execution_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
```

**Permissions Include**:
- ECR image pulling
- CloudWatch logs writing
- No application-level permissions

#### ECS Task Role
```hcl
resource "aws_iam_role" "ecs_task_role" {
  # Separate role for application permissions
  # Can be extended with specific policies as needed
}
```

**Security Benefits**:
- Separation of concerns (execution vs application permissions)
- Fine-grained access control
- No over-privileged access

### 3. Data Security

#### State File Security
```hcl
backend "s3" {
  bucket  = "ecs-webapp-terraform-state-sohaib"
  key     = "terraform.tfstate"
  region  = "us-east-1"
  encrypt = true  # AES-256 encryption
}
```

**Security Features**:
- Server-side encryption enabled
- Versioning for backup and recovery
- Access logging for audit trails
- Bucket policies for access control

#### Secrets Management
- Environment variables for non-sensitive configuration
- AWS Secrets Manager for sensitive data (can be integrated)
- No hardcoded secrets in code or state files

### 4. Container Security

#### Image Security
- Use minimal base images (Alpine, Distroless)
- Regular security scanning with ECR image scanning
- Pin specific image versions, avoid `latest` tag
- Multi-stage builds to reduce attack surface

#### Runtime Security
```dockerfile
# Example secure Dockerfile practices
FROM python:3.9-alpine  # Minimal base image
RUN adduser -D appuser   # Non-root user
USER appuser             # Run as non-root
EXPOSE 5000              # Explicit port declaration
```

#### Health Checks
```hcl
health_check {
  command = ["CMD-SHELL", "curl -f http://localhost:5000/health || exit 1"]
  interval    = 30
  timeout     = 5
  retries     = 3
  start_period = 60
}
```

## Security Monitoring

### CloudWatch Monitoring
- **Container Insights**: Detailed container and service metrics
- **VPC Flow Logs**: Network traffic analysis
- **CloudTrail**: API call logging and auditing
- **GuardDuty**: Threat detection (can be enabled)

### Security Metrics to Monitor
```bash
# Failed authentication attempts
aws logs filter-log-events \
  --log-group-name /ecs/${app_name} \
  --filter-pattern "ERROR" \
  --start-time $(date -d '24 hours ago' +%s)000

# Unusual network patterns
aws ec2 describe-flow-logs --filter "Name=resource-id,Values=${vpc_id}"

# Security group changes
aws logs filter-log-events \
  --log-group-name CloudTrail \
  --filter-pattern "AuthorizeSecurityGroupIngress"
```

## Security Best Practices Checklist

### ✅ Network Security
- [ ] ECS tasks in private subnets
- [ ] Security groups use least privilege
- [ ] No direct internet access to containers
- [ ] VPC Flow Logs enabled
- [ ] Network ACLs configured (if needed)

### ✅ Access Control
- [ ] IAM roles use minimal permissions
- [ ] No hardcoded credentials
- [ ] Resource-based access control
- [ ] Regular access reviews

### ✅ Data Protection
- [ ] Encryption at rest enabled
- [ ] Encryption in transit configured
- [ ] Secrets properly managed
- [ ] State files secured

### ✅ Container Security
- [ ] Minimal base images used
- [ ] Images regularly scanned
- [ ] Non-root container users
- [ ] Security patches applied

### ✅ Monitoring & Auditing
- [ ] CloudWatch monitoring enabled
- [ ] CloudTrail logging configured
- [ ] Security alerts configured
- [ ] Regular security assessments

## Security Enhancements

### Adding HTTPS/TLS
```hcl
# Request ACM certificate
resource "aws_acm_certificate" "main" {
  domain_name       = "your-domain.com"
  validation_method = "DNS"
}

# Update ALB listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.main.arn
}
```

### Adding WAF Protection
```hcl
resource "aws_wafv2_web_acl" "main" {
  name  = "${var.app_name}-waf"
  scope = "REGIONAL"
  
  default_action {
    allow {}
  }
  
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1
    
    override_action {
      none {}
    }
    
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }
}
```

### Adding Secrets Manager
```hcl
resource "aws_secretsmanager_secret" "app_secrets" {
  name = "${var.app_name}-secrets"
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    database_password = "your-secure-password"
    api_key          = "your-api-key"
  })
}
```

## Incident Response

### Security Incident Playbook
1. **Detection**: Monitor CloudWatch alarms and GuardDuty findings
2. **Assessment**: Analyze logs and determine impact
3. **Containment**: Isolate affected resources
4. **Eradication**: Remove threats and vulnerabilities
5. **Recovery**: Restore services securely
6. **Lessons Learned**: Update security controls

### Emergency Procedures
```bash
# Immediately block suspicious IP
aws ec2 create-network-acl-entry \
  --network-acl-id ${nacl_id} \
  --rule-number 1 \
  --protocol -1 \
  --rule-action deny \
  --cidr-block ${suspicious_ip}/32

# Scale down service if compromised
aws ecs update-service \
  --cluster ecs-webapp-cluster \
  --service ${app_name} \
  --desired-count 0

# Check for indicators of compromise
aws logs filter-log-events \
  --log-group-name /ecs/${app_name} \
  --filter-pattern "ERROR|WARN|FAIL" \
  --start-time $(date -d '24 hours ago' +%s)000
```