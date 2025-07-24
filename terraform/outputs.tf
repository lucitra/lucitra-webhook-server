output "service_url" {
  description = "The URL of the deployed webhook service"
  value = var.cloud_provider == "gcp" ? (
    length(module.gcp_deployment) > 0 ? module.gcp_deployment[0].service_url : ""
  ) : (
    length(module.aws_deployment) > 0 ? module.aws_deployment[0].service_url : ""
  )
}

output "webhook_endpoint" {
  description = "The webhook endpoint URL"
  value = var.cloud_provider == "gcp" ? (
    length(module.gcp_deployment) > 0 ? "${module.gcp_deployment[0].service_url}/webhook" : ""
  ) : (
    length(module.aws_deployment) > 0 ? "${module.aws_deployment[0].service_url}/webhook" : ""
  )
}

output "cloud_provider" {
  description = "The cloud provider being used"
  value       = var.cloud_provider
}

output "environment" {
  description = "The deployment environment"
  value       = var.environment
}

output "service_name" {
  description = "The name of the deployed service"
  value       = var.service_name
}