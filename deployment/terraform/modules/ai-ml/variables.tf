variable "region" {
  description = "The GCP region where Vertex AI resources will be created"
  type        = string
}

variable "network" {
  description = "The VPC network ID for private endpoint connectivity (required if enable_private_endpoint is true)"
  type        = string
  default     = null
}

variable "network_name" {
  description = "The VPC network name for private endpoint connectivity (required if enable_private_endpoint is true)"
  type        = string
  default     = null
}

variable "enable_private_endpoint" {
  description = "Whether to enable private service connectivity for Vertex AI resources"
  type        = bool
  default     = false
}

variable "private_range_name" {
  description = "The name of the private IP range reserved for VPC peering with Vertex AI services"
  type        = string
  default     = "vertex-peering-range"
}

variable "private_range_prefix" {
  description = "The prefix length for the private IP range (e.g., 24 for /24 subnet)"
  type        = number
  default     = 24
}

variable "create_index" {
  description = "Whether to create a Vertex AI vector search index for embedding similarity searches"
  type        = bool
  default     = false
}

variable "index_display_name" {
  description = "The display name for the Vertex AI vector search index"
  type        = string
  default     = null
}

variable "index_gcs_uri" {
  description = "The Google Cloud Storage URI containing the vector embeddings data for the index"
  type        = string
  default     = null
}

variable "index_dimensions" {
  description = "The number of dimensions in each vector embedding (typically 768 for many AI models)"
  type        = number
  default     = 768
}

variable "index_distance_measure_type" {
  description = "The distance measure used for vector similarity calculations (COSINE_DISTANCE, DOT_PRODUCT_DISTANCE, or SQUARED_L2_DISTANCE)"
  type        = string
  default     = "COSINE_DISTANCE"
}

variable "index_approx_neighbors" {
  description = "The number of approximate nearest neighbors to return in search results"
  type        = number
  default     = 100
}

variable "index_leaf_node_embedding_count" {
  description = "The number of embeddings stored in each leaf node of the index tree structure"
  type        = number
  default     = 500
}

variable "index_leaf_nodes_to_search_percent" {
  description = "The percentage of leaf nodes to search for better recall vs latency trade-off"
  type        = number
  default     = 7
}

variable "create_endpoint" {
  description = "Whether to create a Vertex AI index endpoint for serving vector search queries"
  type        = bool
  default     = false
}

variable "endpoint_display_name" {
  description = "The display name for the Vertex AI index endpoint"
  type        = string
  default     = null
}

variable "endpoint_public" {
  description = "Whether the index endpoint should be accessible from the public internet (false for VPC-only access)"
  type        = bool
  default     = false
}
