output "cloud_run_service_url" {
  value       = module.cloud_run.uri
  description = "URL of the deployed test service."
}
