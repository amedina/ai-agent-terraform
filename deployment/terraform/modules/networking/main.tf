terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "subnets" {
  for_each                 = { for s in var.subnets : s.name => s }
  name                     = each.value.name
  ip_cidr_range            = each.value.cidr
  region                   = each.value.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = coalesce(each.value.private_ip_google_access, true)
}

resource "google_compute_router" "router" {
  count   = var.enable_nat ? 1 : 0
  name    = var.router_name
  region  = var.router_region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  count                              = var.enable_nat ? 1 : 0
  name                               = var.nat_name
  router                             = google_compute_router.router[0].name
  region                             = var.router_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = var.nat_log_enable
    filter = var.nat_log_filter
  }
}

resource "google_compute_global_address" "private_service_range" {
  count         = var.enable_private_service_connect ? 1 : 0
  name          = var.private_service_range_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.private_service_range_prefix
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_service_connect" {
  count                   = var.enable_private_service_connect ? 1 : 0
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_range[0].name]
}
