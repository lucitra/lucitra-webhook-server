resource "google_project_service" "cloud_run_api" {
  service = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_cloud_run_service" "webhook_server" {
  name     = var.service_name
  location = var.region
  
  depends_on = [google_project_service.cloud_run_api]
  
  template {
    metadata {
      labels = var.labels
      annotations = {
        "autoscaling.knative.dev/maxScale" = tostring(var.max_instances)
        "autoscaling.knative.dev/minScale" = tostring(var.min_instances)
      }
    }
    
    spec {
      containers {
        image = var.image_tag
        
        resources {
          limits = {
            cpu    = var.cpu
            memory = "${var.memory}Mi"
          }
        }
        
        dynamic "env" {
          for_each = var.env_vars
          content {
            name  = env.key
            value = env.value
          }
        }
        
        ports {
          container_port = 8080
        }
      }
      
      service_account_name = google_service_account.webhook_server.email
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.webhook_server.name
  location = google_cloud_run_service.webhook_server.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_service_account" "webhook_server" {
  account_id   = "${var.service_name}-sa"
  display_name = "Service Account for ${var.service_name}"
  description  = "Service account for Cloud Run webhook server"
}

resource "google_project_iam_member" "logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.webhook_server.email}"
}

resource "google_project_iam_member" "metrics" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.webhook_server.email}"
}

# Cloud Armor for DDoS protection
resource "google_compute_security_policy" "webhook_policy" {
  count = var.enable_cloud_armor ? 1 : 0
  
  name = "${var.service_name}-security-policy"
  
  rule {
    action   = "allow"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Allow all traffic"
  }
  
  rule {
    action   = "rate_based_ban"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      conform_action = "allow"
      exceed_action = "deny(429)"
      rate_limit_threshold {
        count        = 100
        interval_sec = 60
      }
      ban_duration_sec = 600
    }
    description = "Rate limit rule"
  }
}