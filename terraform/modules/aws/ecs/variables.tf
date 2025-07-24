variable "region" {
  description = "AWS region"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "env_vars" {
  description = "Environment variables"
  type        = map(string)
  default     = {}
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of tasks"
  type        = number
  default     = 10
}

variable "memory" {
  description = "Memory allocation in MB"
  type        = string
  default     = "512"
}

variable "cpu" {
  description = "CPU allocation (256, 512, 1024, 2048, 4096)"
  type        = string
  default     = "256"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}