data "google_project" "current" {}

resource "google_compute_global_address" "vertex_private_range" {
  count         = var.enable_private_endpoint ? 1 : 0
  name          = var.private_range_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.private_range_prefix
  network       = var.network
}

resource "google_service_networking_connection" "vertex_psc" {
  count                   = var.enable_private_endpoint ? 1 : 0
  network                 = var.network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.vertex_private_range[0].name]
}

resource "google_vertex_ai_index" "index" {
  count        = var.create_index ? 1 : 0
  display_name = var.index_display_name
  region       = var.region
  metadata {
    contents_delta_uri = var.index_gcs_uri
    config {
      dimensions                = var.index_dimensions
      distance_measure_type     = var.index_distance_measure_type
      approximate_neighbors_count = var.index_approx_neighbors
      algorithm_config {
        tree_ah_config {
          leaf_node_embedding_count     = var.index_leaf_node_embedding_count
          leaf_nodes_to_search_percent  = var.index_leaf_nodes_to_search_percent
        }
      }
    }
  }
}

resource "google_vertex_ai_index_endpoint" "endpoint" {
  count                   = var.create_endpoint ? 1 : 0
  display_name            = var.endpoint_display_name
  region                  = var.region
  public_endpoint_enabled = var.endpoint_public
  network                 = var.enable_private_endpoint ? "projects/${data.google_project.current.number}/global/networks/${var.network_name}" : null
  depends_on              = var.enable_private_endpoint ? [google_service_networking_connection.vertex_psc] : []
}
