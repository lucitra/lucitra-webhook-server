cloud_provider = "gcp"
environment    = "prod"
gcp_project_id = "lucitra-ai"
gcp_region     = "us-central1"

# Service configuration
max_instances = 100
min_instances = 2
memory        = "1024"
cpu           = "2"

# Environment variables
env_vars = {
  NODE_ENV  = "production"
  PORT      = "8080"
  LOG_LEVEL = "info"
}