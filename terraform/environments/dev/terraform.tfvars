cloud_provider = "gcp"
environment    = "dev"
gcp_project_id = "lucitra-ai"
gcp_region     = "us-central1"

# Service configuration
max_instances = 10
min_instances = 1
memory        = "512"
cpu           = "1"

# Environment variables
env_vars = {
  NODE_ENV  = "development"
  PORT      = "8080"
  LOG_LEVEL = "debug"
}