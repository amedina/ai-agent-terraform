terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

resource "google_project_service" "enabled" {
  for_each = toset(var.services)
  project  = var.project_id
  service  = each.key
  disable_on_destroy = var.disable_on_destroy
}
