terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "lucitra-terraform-state"
    prefix = "webhook-server"
  }
}

# Provider configurations
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "lucitra-webhook-server"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Local variables
locals {
  common_labels = {
    project     = "lucitra-webhook-server"
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Deploy to the selected cloud provider
module "gcp_deployment" {
  count  = var.cloud_provider == "gcp" ? 1 : 0
  source = "./modules/gcp/cloud-run"

  project_id    = var.gcp_project_id
  region        = var.gcp_region
  service_name  = var.service_name
  image_tag     = var.image_tag
  environment   = var.environment
  env_vars      = var.env_vars
  max_instances = var.max_instances
  min_instances = var.min_instances
  memory        = var.memory
  cpu           = var.cpu
  labels        = local.common_labels
}

module "aws_deployment" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  source = "./modules/aws/ecs"

  region        = var.aws_region
  service_name  = var.service_name
  image_tag     = var.image_tag
  environment   = var.environment
  env_vars      = var.env_vars
  desired_count = var.min_instances
  memory        = var.memory
  cpu           = var.cpu
  tags          = local.common_labels
}