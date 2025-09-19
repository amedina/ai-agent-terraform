terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required APIs
module "apis" {
  source = "../../modules/apis"

  project_id = var.project_id
  services = [
    "run.googleapis.com",
    "storage-component.googleapis.com",
    "storage-api.googleapis.com",
    "iam.googleapis.com"
  ]
}

# Create service account
module "service_account" {
  source = "../../modules/service-account"

  project_id   = var.project_id
  account_id   = var.service_account_id
  display_name = var.service_account_display_name

  depends_on = [module.apis]
}

# Create storage bucket
module "storage" {
  source = "../../modules/storage"

  project_id = var.project_id
  name       = coalesce(var.bucket_name, "${var.project_id}-test-sc-1-bucket")
  location   = var.region

  iam_members = [
    {
      role   = "roles/storage.objectAdmin"
      member = "serviceAccount:${module.service_account.email}"
    }
  ]

  depends_on = [module.service_account]
}

# Deploy Cloud Run service
module "cloud_run" {
  source = "../../modules/cloud-run"

  project_id = var.project_id
  region     = var.region
  name       = var.cloud_run_service_name
  image      = var.image

  service_account = module.service_account.email

  env = {
    BUCKET_NAME = module.storage.bucket_name
  }

  volumes = var.enable_gcs_volume ? [
    {
      name      = "gcs-bucket"
      type      = "gcs"
      bucket    = module.storage.bucket_name
      read_only = false
    }
  ] : []

  volume_mounts = var.enable_gcs_volume ? [
    {
      name       = "gcs-bucket"
      mount_path = var.gcs_mount_path
    }
  ] : []

  invokers = {
    "user-access" = ["user:${var.user_email}"]
  }

  depends_on = [module.storage]
}
