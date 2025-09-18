resource "google_redis_instance" "this" {
  name           = var.name
  project        = var.project_id
  region         = var.region
  tier           = var.tier
  memory_size_gb = var.memory_size_gb
  replica_count  = var.replica_count
  authorized_network = var.authorized_network
}
