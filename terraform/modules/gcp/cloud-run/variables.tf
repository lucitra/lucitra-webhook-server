variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "service_name" {
  description = "Name of the Cloud Run service"
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
  description = "Memory allocation in MB"
  type        = string
  default     = "512"
}

variable "cpu" {
  description = "CPU allocation"
  type        = string
  default     = "1"
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "enable_cloud_armor" {
  description = "Enable Cloud Armor for DDoS protection"
  type        = bool
  default     = true
}