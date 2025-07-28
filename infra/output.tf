output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "load_balancer_url" {
  description = "Load balancer URL"
  value       = var.enable_https ? "https://${var.route53_record_name}" : "http://${module.alb.alb_dns_name}"
}

output "load_balancer_dns_name" {
  description = "Load balancer DNS name"
  value       = module.alb.alb_dns_name
}

output "load_balancer_zone_id" {
  description = "Load balancer zone ID"
  value       = module.alb.alb_zone_id
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.service_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecs.ecr_repository_url
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group name"
  value       = module.ecs.log_group_name
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID"
  value       = var.enable_https ? module.route53.zone_id : null
}

output "route53_name_servers" {
  description = "Route53 name servers (update your domain registrar with these)"
  value       = var.enable_https ? module.route53.zone_name_servers : []
}

output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = var.enable_https ? module.acm[0].certificate_arn : null
}
