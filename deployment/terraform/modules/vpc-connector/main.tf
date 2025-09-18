resource "google_vpc_access_connector" "this" {
  name          = var.name
  project       = var.project_id
  region        = var.region
  network       = var.network
  subnetwork    = var.subnetwork
  ip_cidr_range = var.ip_cidr_range
  min_instances = var.min_instances
  max_instances = var.max_instances
}
