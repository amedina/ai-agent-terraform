variable "project_id" {
  type        = string
  description = "The GCP project ID."
}

variable "region" {
  description = "The GCP region for deployment."
  type        = string
  default     = "us-central1"
}

variable "user_email" {
  description = "The email address of the user who can invoke the Cloud Run service"
  type        = string
}

# Scenario-specific variables with sensible defaults to match module inputs
variable "service_account_id" {
  description = "Service account ID (without domain) for the Cloud Run service"
  type        = string
  default     = "test-sc-1-sa"
}

variable "service_account_display_name" {
  description = "Display name for the service account"
  type        = string
  default     = "Test Scenario 1 Service Account"
}

variable "bucket_name" {
  description = "Name of the GCS bucket to create for the scenario"
  type        = string
  default     = null
}

variable "cloud_run_service_name" {
  description = "Name of the Cloud Run service"
  type        = string
  default     = "test-sc-1-service"
}

variable "image" {
  description = "Container image to deploy to Cloud Run"
  type        = string
  default     = "gcr.io/cloudrun/hello"
}

variable "enable_gcs_volume" {
  description = "Whether to mount the GCS bucket as a volume in the Cloud Run service"
  type        = bool
  default     = false
}

variable "gcs_mount_path" {
  description = "Mount path inside the container for the GCS bucket (effective when enable_gcs_volume is true)"
  type        = string
  default     = "/mnt/bucket"
}
