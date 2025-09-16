output "service_name" {
  description = "The name of the deployed Cloud Run service"
  value       = google_cloud_run_v2_service.this.name
}

output "uri" {
  description = "The URI of the deployed Cloud Run service for HTTP requests"
  value       = google_cloud_run_v2_service.this.uri
}
