output "email" {
  value       = google_service_account.this.email
  description = "Service account email"
}

output "name" {
  value       = google_service_account.this.name
  description = "Service account resource name"
}
