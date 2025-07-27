# 🏗️ Infrastructure Components

This document details all the AWS infrastructure components created by this project.

## 1. Virtual Private Cloud (VPC)
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

## 2. Public Subnets
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

## 3. Private Subnets
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

## 4. Internet Gateway
```hcl
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}
```
**Purpose**: Provides internet access for public subnets

**Configuration**: Attached to VPC for bidirectional internet connectivity

## 5. NAT Gateways
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

## 6. Route Tables and Associations
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

## 7. Application Load Balancer (ALB)
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

## 8. Target Group
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

## 9. Security Groups

### ALB Security Group
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

### ECS Tasks Security Group
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

## 10. ECS Cluster
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

## 11. ECS Task Definition
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

## 12. ECS Service
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

## 13. Auto Scaling
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

## 14. IAM Roles

### ECS Task Execution Role
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

### ECS Task Role
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

## 15. CloudWatch Log Group
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