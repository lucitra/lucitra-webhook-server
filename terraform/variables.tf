variable "cloud_provider" {
  description = "Cloud provider to deploy to (gcp or aws)"
  type        = string
  default     = "gcp"

  validation {
    condition     = contains(["gcp", "aws"], var.cloud_provider)
    error_message = "Cloud provider must be either 'gcp' or 'aws'"
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "service_name" {
  description = "Name of the webhook service"
  type        = string
  default     = "lucitra-webhook-server"
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

# GCP Variables
variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
  default     = "lucitra-ai"
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

# AWS Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Service Configuration
variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 100
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Memory allocation (MB for GCP, MB for AWS)"
  type        = string
  default     = "512"
}

variable "cpu" {
  description = "CPU allocation (cores for GCP, CPU units for AWS)"
  type        = string
  default     = "1"
}

variable "env_vars" {
  description = "Environment variables for the service"
  type        = map(string)
  default = {
    NODE_ENV = "production"
    PORT     = "8080"
  }
  sensitive = true
}

variable "domain_name" {
  description = "Custom domain name for the webhook server"
  type        = string
  default     = ""
}

variable "enable_https" {
  description = "Enable HTTPS with managed certificate"
  type        = bool
  default     = true
}