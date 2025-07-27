# 🔍 Troubleshooting Guide

## Common Issues

### 1. Tasks Not Starting
**Symptoms**: ECS service shows desired count but running count is 0

**Possible Causes**:
- Container fails to start
- Insufficient CPU/memory
- Image pull failures
- Health check failures

**Solutions**:
```bash
# Check CloudWatch logs
aws logs tail /ecs/${app_name} --follow

# Check ECS service events
aws ecs describe-services --cluster ecs-webapp-cluster --services ${app_name}

# Check task definition
aws ecs describe-task-definition --task-definition ${app_name}
```

### 2. Health Check Failures
**Symptoms**: Tasks start but fail health checks

**Possible Causes**:
- Incorrect health check path
- Application not responding on expected port
- Health check timeout too short
- Application startup time longer than grace period

**Solutions**:
```bash
# Check target group health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# Verify health check configuration
aws elbv2 describe-target-groups --target-group-arns <target-group-arn>

# Test health endpoint locally
curl http://<alb-dns-name>/health
```

**Configuration Fixes**:
- Increase `health_check_timeout`
- Adjust `health_check_interval`
- Verify `health_check_path` is correct
- Increase `container_health_check_start_period`

### 3. 502 Bad Gateway Errors
**Symptoms**: ALB returns 502 errors

**Possible Causes**:
- Container port mismatch
- No healthy targets
- Security group blocking traffic
- Application not binding to correct interface

**Solutions**:
```bash
# Check if targets are healthy
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# Verify security groups
aws ec2 describe-security-groups --group-ids <security-group-id>

# Check container logs
aws logs tail /ecs/${app_name} --follow
```

**Configuration Fixes**:
- Ensure `container_port` matches application port
- Verify security group allows ALB → ECS communication
- Check application binds to `0.0.0.0` not `127.0.0.1`

### 4. Auto Scaling Not Working
**Symptoms**: Service doesn't scale despite high CPU/memory

**Possible Causes**:
- Scaling policies not configured correctly
- CloudWatch metrics not available
- Target values unrealistic
- Scale-out/scale-in cooldowns

**Solutions**:
```bash
# Check auto scaling target
aws application-autoscaling describe-scalable-targets --service-namespace ecs

# Check scaling policies
aws application-autoscaling describe-scaling-policies --service-namespace ecs

# Check CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ServiceName,Value=${app_name} \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

### 5. Image Pull Failures
**Symptoms**: Tasks fail to start with image pull errors

**Possible Causes**:
- ECR permissions
- Image doesn't exist
- Network connectivity issues
- Task execution role missing permissions

**Solutions**:
```bash
# Check ECR repository
aws ecr describe-repositories --repository-names ${ecr_repository_name}

# Check image exists
aws ecr list-images --repository-name ${ecr_repository_name}

# Check task execution role permissions
aws iam get-role --role-name ${app_name}-ecs-task-execution-role
```

## Useful Commands

### ECS Debugging
```bash
# View ECS service status
aws ecs describe-services --cluster ecs-webapp-cluster --services ${app_name}

# View running tasks
aws ecs list-tasks --cluster ecs-webapp-cluster --service-name ${app_name}

# View task details
aws ecs describe-tasks --cluster ecs-webapp-cluster --tasks <task-arn>

# View service events
aws ecs describe-services --cluster ecs-webapp-cluster --services ${app_name} \
  --query 'services[0].events[:10]' --output table
```

### Load Balancer Debugging
```bash
# Check load balancer health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# View load balancer attributes
aws elbv2 describe-load-balancers --names ecs-webapp-alb

# Check listener rules
aws elbv2 describe-listeners --load-balancer-arn <alb-arn>
```

### CloudWatch Logs
```bash
# View logs
aws logs tail /ecs/${app_name} --follow

# View log streams
aws logs describe-log-streams --log-group-name /ecs/${app_name}

# Get specific time range
aws logs filter-log-events \
  --log-group-name /ecs/${app_name} \
  --start-time $(date -d '1 hour ago' +%s)000 \
  --end-time $(date +%s)000
```

### CloudWatch Metrics
```bash
# Check ECS service metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ServiceName,Value=${app_name} Name=ClusterName,Value=ecs-webapp-cluster \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average,Maximum

# Check ALB metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --dimensions Name=LoadBalancer,Value=<alb-full-name> \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

## Performance Optimization

### Right-sizing Resources
- Monitor CPU and memory utilization
- Adjust `cpu` and `memory` based on actual usage
- Use CloudWatch Container Insights for detailed metrics

### Auto Scaling Tuning
- Set realistic `cpu_target_value` and `memory_target_value`
- Monitor scaling events and adjust thresholds
- Consider custom metrics for application-specific scaling

### Cost Optimization
- Use appropriate CPU/memory combinations
- Monitor unused capacity
- Consider Spot instances for non-production workloads
- Optimize log retention periods

## Security Best Practices

### Network Security
- Ensure ECS tasks are in private subnets
- Verify security groups follow least privilege
- Use VPC Flow Logs for network monitoring

### IAM Security
- Review task and execution role permissions
- Use IAM Access Analyzer to identify unused permissions
- Enable CloudTrail for API logging

### Container Security
- Scan images for vulnerabilities
- Use minimal base images
- Keep dependencies updated
- Enable GuardDuty for threat detection