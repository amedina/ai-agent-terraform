output "vpc_id" {
  value       = google_compute_network.vpc.id
  description = "VPC self link"
}

output "subnet_ids" {
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.id }
  description = "Map of subnet ids"
}

output "private_service_connect_enabled" {
  description = "Whether Private Service Connect (Service Networking) is enabled for this VPC"
  value       = var.enable_private_service_connect
}
