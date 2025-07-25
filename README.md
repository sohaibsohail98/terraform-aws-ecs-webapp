# Sohaib Sohail - DevOps Portfolio Application

## Local Setup:

To set this up locally:

Clone the repo and make sure you have Python installed.

- cd into the project directory
- run ```pip install -r requirements.txt```
- run ```python3 app.py```

Check your browser for localhost:8080.

## 🎯 Current Application

This repository now showcases a **professional portfolio web application** for **Sohaib Sohail**, DevOps Engineer at PwC, featuring:

### 👨‍💻 Portfolio Features
- **Professional Profile**: Showcasing 4+ years of cloud engineering experience at PwC and Capgemini
- **Technical Skills Display**: AWS, Azure, Terraform, CI/CD, DevSecOps expertise
- **Certifications**: Terraform Associate, Azure Fundamentals, AWS Cloud Practitioner  
- **Interactive Snake Game**: DevOps-themed educational game with professional branding
- **Modern Responsive Design**: Clean, professional interface suitable for demonstrations

### 🐳 Application Stack
- **Backend**: Flask (Python) with RESTful API endpoints
- **Frontend**: Modern CSS with responsive design
- **Container**: Production-ready Docker configuration
- **Health Monitoring**: `/health` endpoint for ECS health checks
- **Game API**: Score tracking and management endpoints

### 📁 Current Project Structure
```
├── app.py                 # Main Flask application (NEW - Portfolio & Game)
├── requirements.txt       # Simplified dependencies (Flask + Gunicorn)
├── Dockerfile            # Production-ready container (Compatible with ECS)
├── templates/
│   ├── home.html         # Professional portfolio homepage
│   └── game.html         # Interactive Snake game
├── dvla_archive/         # Original DVLA application (Archived)
│   ├── original_app.py   # Previous DVLA checker app
│   ├── dvla_service.py   # DVLA API service
│   └── API_SETUP.md      # DVLA setup documentation
└── infra/               # Terraform infrastructure (UNCHANGED)
    ├── main.tf          # Networking and load balancer
    ├── ecs.tf           # ECS cluster and services  
    ├── variables.tf     # Variable definitions
    ├── terraform.tfvars # Environment configuration
    ├── provider.tf      # AWS provider and backend
    └── outputs.tf       # Output values
```

### 🚀 Quick Start - New Application
```bash
# Local development
export FLASK_SECRET_KEY=$(python -c "import secrets; print(secrets.token_hex(32))")
pip install -r requirements.txt
python app.py
# Visit: http://localhost:5000 (Portfolio) | http://localhost:5000/game (Snake Game)

# Docker deployment
docker build -t sohaib-portfolio .
docker run -p 5000:5000 -e FLASK_SECRET_KEY=your_secret_key sohaib-portfolio
```

### 🔧 ECS Deployment Compatibility
The new application maintains full compatibility with the existing Terraform ECS infrastructure:
- **Port**: Still uses port 5000 (matches ECS configuration)
- **Health Check**: `/health` endpoint (matches ALB target group)
- **Container**: Same Dockerfile structure with gunicorn
- **Environment**: Flask secret key configurable via environment variables

---

# terraform-aws-ecs-webapp

A production-ready, highly available ECS Fargate web application infrastructure deployed on AWS using Terraform. This project demonstrates infrastructure-as-code best practices with complete CI/CD integration, remote state management, and comprehensive security configurations.

## 🚀 Project Overview

This repository deploys a scalable containerized web application using:
- **AWS ECS Fargate** for serverless container orchestration
- **Application Load Balancer** for high availability and traffic distribution
- **Multi-AZ deployment** across public and private subnets
- **Auto-scaling** based on CPU and memory utilization
- **Comprehensive monitoring** with CloudWatch and Container Insights
- **Security-first architecture** with least privilege access

## 📋 Setup Steps

### What I Did First

#### 1. Created Backend Infrastructure for Remote State Storage

**Why**: Terraform state files contain sensitive information and need to be shared across team members and CI/CD pipelines. Remote state storage provides consistency, security, and enables state locking.

**What I Created**:
- I created a S3 Bucket for the Terraform State
- Enabled versioning
- Enabled server-side encryption

**Backend Configuration**:
```hcl
# In provider.tf
backend "s3" {
  bucket         = "ecs-webapp-terraform-state-sohaib"
  key            = "terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  use_lockfile = true
}
```

This is crucial because it allows the new lock file functionality from Terraform in its latest update to lock the state file as default instead of relying on DynamoDB's state locking. This has only recently been updated in Terraform.

#### 2. Created GitHub Actions Workflow for Terraform Plan

**Why**: Automated validation ensures code quality, security, and prevents configuration drift. The workflow validates Terraform syntax, formatting, and generates execution plans for review.

**Workflow Features**:
- **AWS Authentication**: Uses OIDC for secure, keyless AWS access
- **Security Scanning**: Using Checkov, Terratest and TF Lint (Temporarily commented out)
- **Terraform Validation**: Runs `terraform fmt`, `terraform validate`
- **Plan Generation**: Creates detailed execution plans for review
- **Security Scanning using TF**: Validates configurations against best practices
- **Multi-Environment Support**: Can be extended for dev/staging/prod

**Workflow Configuration** (`.github/workflows/terraform-plan.yml`):
```yaml
name: 'Terraform Plan'

on:
  pull_request:
    branches: [ main ]
    paths: [ 'terraform/**' ]

permissions:
  id-token: write   # Required for OIDC
  contents: read    # Required to checkout code
  pull-requests: write  # Required to comment on PRs

jobs:
  terraform-plan:
    name: 'Terraform Plan'
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/GitHubActionsRole
        aws-region: us-east-1

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: 1.9.0

    - name: Terraform Format Check
      working-directory: ./terraform
      run: terraform fmt -check -recursive

    - name: Terraform Init
      working-directory: ./terraform
      run: terraform init

    - name: Terraform Validate
      working-directory: ./terraform
      run: terraform validate

    - name: Terraform Plan
      working-directory: ./terraform
      run: terraform plan -var-file="terraform.tfvars" -out=tfplan

    - name: Comment PR
      uses: actions/github-script@v7
      with:
        script: |
          const output = `#### Terraform Format and Style 🖌\`${{ steps.fmt.outcome }}\`
          #### Terraform Initialization ⚙️\`${{ steps.init.outcome }}\`
          #### Terraform Validation 🤖\`${{ steps.validate.outcome }}\`
          #### Terraform Plan 📖\`${{ steps.plan.outcome }}\`

          *Pusher: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;

          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: output
          })
```

#### 3. Created Terraform Infrastructure Code

**Why**: Infrastructure-as-code provides version control, repeatability, and documentation for cloud resources. The modular approach ensures maintainability and reusability across environments.

**Code Organization**:
```
terraform/
├── main.tf          # Networking and load balancer resources
├── ecs.tf           # ECS cluster, service, and task definitions
├── variables.tf     # Variable definitions (no defaults)
├── terraform.tfvars # Environment-specific configurations
├── provider.tf      # Provider and backend configuration
└── outputs.tf       # Output values for integration
```

## 🏗️ Infrastructure Components

### 1. **Virtual Private Cloud (VPC)**
```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}
```
**Purpose**: Provides isolated network environment for the application
**Configuration**:
- DNS resolution enabled for service discovery
- Custom CIDR block for network isolation
- Foundation for all other networking components

### 2. **Public Subnets**
```hcl
resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = data.aws_availability_zones.available.names[each.value.az_index]
  map_public_ip_on_launch = true
}
```
**Purpose**: Host internet-facing resources (load balancer, NAT gateways)
**Configuration**:
- Multi-AZ deployment for high availability
- Auto-assign public IPs for internet connectivity
- Houses ALB and NAT gateways only

### 3. **Private Subnets**
```hcl
resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = data.aws_availability_zones.available.names[each.value.az_index]
}
```
**Purpose**: Host application containers in isolated environment
**Configuration**:
- No direct internet access for security
- ECS tasks deployed here
- Outbound internet access via NAT gateways

### 4. **Internet Gateway**
```hcl
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}
```
**Purpose**: Provides internet access for public subnets
**Configuration**: Attached to VPC for bidirectional internet connectivity

### 5. **NAT Gateways**
```hcl
resource "aws_nat_gateway" "main" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id
}
```
**Purpose**: Provides outbound internet access for private subnets
**Configuration**:
- One NAT gateway per AZ for high availability
- Elastic IPs for consistent outbound IP addresses
- Enables container image pulls and external API calls

### 6. **Route Tables and Associations**
```hcl
# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

# Private route tables
resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[...].id
  }
}
```
**Purpose**: Define network traffic routing rules
**Configuration**:
- Public subnets route to Internet Gateway
- Private subnets route to NAT Gateway
- Separate route tables for granular control

### 7. **Application Load Balancer (ALB)**
```hcl
resource "aws_lb" "main" {
  name               = "ecs-webapp-alb"
  internal           = false
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]
}
```
**Purpose**: Distributes incoming traffic across multiple ECS tasks
**Configuration**:
- Internet-facing for external access
- Multi-AZ deployment for high availability
- Health checks ensure traffic only goes to healthy containers
- Can handle HTTP/HTTPS traffic

### 8. **Target Group**
```hcl
resource "aws_lb_target_group" "main" {
  name        = "ecs-webapp-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }
}
```
**Purpose**: Defines health check parameters and routing for ECS tasks
**Configuration**:
- IP target type for Fargate compatibility
- Configurable health check parameters
- Monitors application health and removes unhealthy tasks

### 9. **Security Groups**

#### ALB Security Group
```hcl
resource "aws_security_group" "alb" {
  name_prefix = "ecs-webapp-alb-"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = var.alb_listener_port
    to_port     = var.alb_listener_port
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidr_blocks
  }
}
```
**Purpose**: Controls traffic to load balancer
**Configuration**:
- Configurable ingress ports and CIDR blocks
- Allows external traffic on specified ports
- Restricts access based on requirements

#### ECS Tasks Security Group
```hcl
resource "aws_security_group" "ecs_tasks" {
  name_prefix = "ecs-webapp-tasks-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
}
```
**Purpose**: Controls traffic to ECS containers
**Configuration**:
- Only allows traffic from ALB security group
- Implements least privilege access
- No direct external access to containers

### 10. **ECS Cluster**
```hcl
resource "aws_ecs_cluster" "main" {
  name = "ecs-webapp-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }
}
```
**Purpose**: Logical grouping of compute resources for containers
**Configuration**:
- Container Insights for monitoring (configurable)
- Serverless compute with Fargate
- Centralized management of services

### 11. **ECS Task Definition**
```hcl
resource "aws_ecs_task_definition" "main" {
  family                   = var.app_name
  network_mode             = var.network_mode
  requires_compatibilities = [var.launch_type]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([...])
}
```
**Purpose**: Defines container specifications and resource requirements
**Configuration**:
- Fargate launch type for serverless execution
- Configurable CPU and memory allocation
- IAM roles for secure AWS service access
- Health checks and logging configuration

### 12. **ECS Service**
```hcl
resource "aws_ecs_service" "main" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = [for subnet in aws_subnet.private : subnet.id]
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = var.app_name
    container_port   = var.container_port
  }
}
```
**Purpose**: Manages desired state and deployment of containers
**Configuration**:
- Maintains specified number of running tasks
- Integrates with load balancer for traffic distribution
- Deployed in private subnets for security
- Rolling deployments for zero-downtime updates

### 13. **Auto Scaling**
```hcl
# Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU-based scaling policy
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "${var.app_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.cpu_target_value
  }
}
```
**Purpose**: Automatically scales containers based on demand
**Configuration**:
- CPU and memory-based scaling policies
- Configurable target utilization thresholds
- Prevents over-provisioning and under-provisioning
- Ensures application performance during traffic spikes

### 14. **IAM Roles**

#### ECS Task Execution Role
```hcl
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}-ecs-task-execution-role"

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
```
**Purpose**: Allows ECS to pull images and write logs
**Configuration**:
- Minimal permissions for task execution
- CloudWatch logs access
- ECR image pulling permissions

#### ECS Task Role
```hcl
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.app_name}-ecs-task-role"
  # ... similar assume role policy
}
```
**Purpose**: Provides application-specific AWS permissions
**Configuration**:
- Can be extended for application needs (S3, DynamoDB, etc.)
- Follows least privilege principle
- Separate from execution role for security

### 15. **CloudWatch Log Group**
```hcl
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = var.log_retention_days
}
```
**Purpose**: Centralized logging for application containers
**Configuration**:
- Configurable retention period
- Structured log path for organization
- Enables log aggregation and monitoring

## 🔧 Configuration

### Comprehensive Variabilization

This configuration is fully variabilized with **no hardcoded values**. All aspects can be customized:

- **Infrastructure**: VPC, subnets, security groups, load balancers
- **ECS Configuration**: Task definitions, services, scaling policies  
- **Health Checks**: Both ALB and container-level health checking
- **Monitoring**: CloudWatch settings and Container Insights
- **Security**: CIDR blocks, ports, protocols, and access controls

### Key Variables

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

#### ECS Configuration
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

#### Load Balancer Configuration
| Variable | Description | Type | Example |
|----------|-------------|------|---------|
| `alb_listener_port` | ALB listener port | number | `80` |
| `alb_listener_protocol` | ALB listener protocol | string | `"HTTP"` |
| `load_balancer_type` | Load balancer type | string | `"application"` |
| `enable_deletion_protection` | Enable deletion protection | bool | `false` |
| `alb_ingress_cidr_blocks` | CIDR blocks for ALB access | list(string) | `["0.0.0.0/0"]` |

#### Health Check Configuration
| Variable | Description | Type | Example |
|----------|-------------|------|---------|
| `health_check_healthy_threshold` | Consecutive healthy checks required | number | `3` |
| `health_check_interval` | Health check interval (seconds) | number | `30` |
| `health_check_timeout` | Health check timeout (seconds) | number | `5` |
| `health_check_unhealthy_threshold` | Consecutive unhealthy checks required | number | `2` |
| `health_check_matcher` | HTTP status codes for healthy | string | `"200"` |

#### Auto Scaling Configuration
| Variable | Description | Type | Example |
|----------|-------------|------|---------|
| `cpu_target_value` | CPU utilization target % | number | `70.0` |
| `memory_target_value` | Memory utilization target % | number | `80.0` |

#### Container Health Check Configuration
| Variable | Description | Type | Example |
|----------|-------------|------|---------|
| `container_health_check_interval` | Container health check interval | number | `30` |
| `container_health_check_timeout` | Container health check timeout | number | `5` |
| `container_health_check_retries` | Container health check retries | number | `3` |
| `container_health_check_start_period` | Container health check start period | number | `60` |

#### Monitoring Configuration
| Variable | Description | Type | Example |
|----------|-------------|------|---------|
| `log_retention_days` | CloudWatch log retention days | number | `7` |
| `enable_container_insights` | Enable Container Insights | bool | `true` |

## 🚀 Quick Start

### 1. Clone and Configure

```bash
git clone <your-repo>
cd terraform/
```

### 2. Configure Variables

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

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan and Apply

```bash
terraform plan
terraform apply
```

### 5. Access Your Application

After deployment, your application will be available at the load balancer URL shown in the outputs:

```bash
terraform output load_balancer_url
```

## 🔒 Security Features

- **Network Isolation**: ECS tasks run in private subnets with no direct internet access
- **Security Groups**: Least privilege access with port restrictions
- **IAM Roles**: Minimal permissions following AWS best practices
- **Encryption**: State files encrypted in S3
- **State Locking**: Prevents concurrent modifications with DynamoDB
- **HTTPS Support**: Configurable SSL/TLS termination at load balancer

## 📊 Monitoring and Logging

- **CloudWatch Logs**: Centralized application logging
- **Container Insights**: Detailed container metrics (configurable)
- **Auto Scaling Metrics**: CPU and memory utilization tracking
- **Health Check Monitoring**: Load balancer and container health status
- **AWS X-Ray**: Distributed tracing (can be enabled)

## 🔄 CI/CD Integration

The project includes GitHub Actions workflow for:
- **Terraform Validation**: Syntax and configuration checks
- **Security Scanning**: Infrastructure security analysis
- **Plan Generation**: Automated plan creation for PRs
- **Multi-Environment**: Support for dev/staging/prod pipelines

## 💰 Cost Optimization

- **Fargate Pricing**: Pay only for resources used
- **Auto Scaling**: Automatic scaling based on demand
- **Configurable Resources**: Right-size CPU and memory
- **Log Retention**: Configurable retention periods
- **Multi-AZ NAT**: Can be reduced to single AZ for dev environments

## 🛠️ Customization Examples

### Adding HTTPS

1. Create ACM certificate
2. Update `alb_listener_port = 443` and `alb_listener_protocol = "HTTPS"`
3. Add certificate ARN to listener configuration

### Database Integration

1. Add RDS subnet group in private subnets
2. Create database security group
3. Add environment variables to ECS task definition
4. Configure connection strings

### Custom Domain

1. Create Route 53 hosted zone
2. Add alias record pointing to ALB
3. Update health checks if needed

## 🔍 Troubleshooting

### Common Issues

1. **Tasks not starting**: Check CloudWatch logs for container errors
2. **Health check failures**: Verify health check path and timeouts
3. **502 errors**: Ensure container port matches target group port
4. **Auto scaling not working**: Check CloudWatch metrics and policies

### Useful Commands

```bash
# View ECS service status
aws ecs describe-services --cluster ecs-webapp-cluster --services ecs-webapp

# View running tasks
aws ecs list-tasks --cluster ecs-webapp-cluster --service-name ecs-webapp

# View logs
aws logs tail /ecs/ecs-webapp --follow

# Check load balancer health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

## 🧹 Cleanup

```bash
terraform destroy
```

## 📚 Additional Resources

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Container Security Best Practices](https://aws.amazon.com/blogs/containers/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test thoroughly
4. Submit a pull request with detailed description
5. Ensure all CI checks pass

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.