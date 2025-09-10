output "enabled_services" {
  description = "List of enabled services"
  value       = keys(google_project_service.enabled)
}
