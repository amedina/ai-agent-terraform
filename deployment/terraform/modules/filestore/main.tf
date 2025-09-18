resource "google_filestore_instance" "this" {
  name       = var.name
  project    = var.project_id
  location   = var.location
  tier       = var.tier

  file_shares {
    capacity_gb = var.capacity_gb
    name        = var.share_name
  }

  networks {
    network = var.network
    modes   = ["MODE_IPV4"]
    reserved_ip_range = var.reserved_ip_range
  }
}
