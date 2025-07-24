output "service_url" {
  description = "URL of the load balancer"
  value       = "http://${aws_lb.webhook_alb.dns_name}"
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.webhook_alb.dns_name
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.webhook_cluster.name
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.webhook_server.name
}