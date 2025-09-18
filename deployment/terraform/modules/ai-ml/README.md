# AI/ML Module

This Terraform module provisions Google Cloud Vertex AI resources for AI/ML workloads, including vector search indexes and endpoints with optional private networking configuration.

## Features

- **Vertex AI Index**: Create and manage vector search indexes for similarity search
- **Vertex AI Index Endpoint**: Deploy endpoints for serving vector search queries
- **Private Networking**: Optional private endpoint configuration with VPC peering
- **Configurable Search**: Support for various distance measures and algorithm configurations

## Resources Created

- `google_compute_global_address` - Private IP range for VPC peering (optional)
- `google_service_networking_connection` - VPC peering connection for private services (optional)
- `google_vertex_ai_index` - Vector search index (optional)
- `google_vertex_ai_index_endpoint` - Index endpoint for serving queries (optional)

## Usage

### Basic Vector Search Index

```hcl
module "ai_ml" {
  source = "./modules/ai-ml"
  
  region = "us-central1"
  
  create_index = true
  index_display_name = "document-embeddings"
  index_gcs_uri = "gs://my-bucket/embeddings/"
  index_dimensions = 768
  index_distance_measure_type = "COSINE_DISTANCE"
}
```

### Vector Search with Private Endpoint

```hcl
module "ai_ml" {
  source = "./modules/ai-ml"
  
  region = "us-central1"
  network = "projects/my-project/global/networks/my-vpc"
  network_name = "my-vpc"
  
  enable_private_endpoint = true
  private_range_name = "vertex-ai-range"
  private_range_prefix = 24
  
  create_index = true
  index_display_name = "private-embeddings"
  index_gcs_uri = "gs://my-bucket/embeddings/"
  
  create_endpoint = true
  endpoint_display_name = "private-search-endpoint"
  endpoint_public = false
}
```

### Full Configuration with Custom Algorithm Settings

```hcl
module "ai_ml" {
  source = "./modules/ai-ml"
  
  region = "us-central1"
  
  create_index = true
  index_display_name = "custom-embeddings"
  index_gcs_uri = "gs://my-bucket/embeddings/"
  index_dimensions = 1536
  index_distance_measure_type = "DOT_PRODUCT_DISTANCE"
  index_approx_neighbors = 150
  index_leaf_node_embedding_count = 1000
  index_leaf_nodes_to_search_percent = 10
  
  create_endpoint = true
  endpoint_display_name = "custom-search-endpoint"
  endpoint_public = true
}
```

## Variables

### Required Variables

| Name | Type | Description |
|------|------|-------------|
| `region` | `string` | The GCP region where resources will be created |

### Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `network` | `string` | `null` | VPC network for private endpoint |
| `network_name` | `string` | `null` | Name of the VPC network |
| `enable_private_endpoint` | `bool` | `false` | Enable private endpoint configuration |
| `private_range_name` | `string` | `"vertex-peering-range"` | Name for the private IP range |
| `private_range_prefix` | `number` | `24` | Prefix length for private IP range |

### Index Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create_index` | `bool` | `false` | Whether to create a Vertex AI index |
| `index_display_name` | `string` | `null` | Display name for the index |
| `index_gcs_uri` | `string` | `null` | GCS URI containing the index data |
| `index_dimensions` | `number` | `768` | Number of dimensions in the embeddings |
| `index_distance_measure_type` | `string` | `"COSINE_DISTANCE"` | Distance measure type (COSINE_DISTANCE, DOT_PRODUCT_DISTANCE, SQUARED_L2_DISTANCE) |
| `index_approx_neighbors` | `number` | `100` | Number of approximate neighbors to return |
| `index_leaf_node_embedding_count` | `number` | `500` | Number of embeddings in each leaf node |
| `index_leaf_nodes_to_search_percent` | `number` | `7` | Percentage of leaf nodes to search |

### Endpoint Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create_endpoint` | `bool` | `false` | Whether to create a Vertex AI index endpoint |
| `endpoint_display_name` | `string` | `null` | Display name for the endpoint |
| `endpoint_public` | `bool` | `false` | Whether the endpoint should be publicly accessible |

## Outputs

| Name | Description |
|------|-------------|
| `index_id` | The ID of the created Vertex AI index (if created) |
| `endpoint_id` | The ID of the created Vertex AI index endpoint (if created) |

## Prerequisites

### APIs Required

The following Google Cloud APIs must be enabled in your project:

```hcl
module "apis" {
  source = "./modules/apis"
  
  apis = [
    "aiplatform.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com"  # Required for private endpoints
  ]
}
```

### IAM Permissions

The service account or user running Terraform needs the following roles:

- `roles/aiplatform.admin` - For managing Vertex AI resources
- `roles/compute.networkAdmin` - For VPC peering (if using private endpoints)
- `roles/servicenetworking.networksAdmin` - For service networking (if using private endpoints)

### Data Preparation

Before creating an index, you need to prepare your embeddings data:

1. Generate embeddings for your documents/items
2. Format the data according to [Vertex AI requirements](https://cloud.google.com/vertex-ai/docs/matching-engine/setup/format-structure)
3. Upload to Google Cloud Storage
4. Provide the GCS URI to the `index_gcs_uri` variable

## Distance Measure Types

The module supports the following distance measures:

- **COSINE_DISTANCE**: Measures the cosine of the angle between vectors
- **DOT_PRODUCT_DISTANCE**: Measures the dot product between vectors
- **SQUARED_L2_DISTANCE**: Measures the squared Euclidean distance

Choose the appropriate measure based on your embedding model and use case.

## Private Endpoint Configuration

When `enable_private_endpoint` is set to `true`, the module:

1. Creates a private IP address range for VPC peering
2. Establishes a service networking connection
3. Configures the index endpoint to use private networking
4. Restricts access to resources within the specified VPC

This is recommended for production deployments requiring network isolation.

## Example Scenarios

This module is used in the following sample scenarios:

- **scenario-7-cloud-run-vector-search**: Demonstrates Cloud Run integration with Vertex AI vector search
- **scenario-12-cloud-run-agent-engine**: Shows usage in AI agent engine deployments

## Limitations

- Index creation can take 30-60 minutes for large datasets
- Private endpoints require proper VPC configuration
- Index updates require recreating the resource
- Region availability may vary for Vertex AI services

## Troubleshooting

### Common Issues

1. **API not enabled**: Ensure all required APIs are enabled in your project
2. **Insufficient permissions**: Verify IAM roles are correctly assigned
3. **Invalid GCS URI**: Check that the embeddings data is properly formatted and accessible
4. **Network configuration**: For private endpoints, ensure VPC and subnets are properly configured

### Monitoring

After deployment, monitor your Vertex AI resources through:

- Google Cloud Console > Vertex AI > Matching Engine
- Cloud Monitoring for performance metrics
- Cloud Logging for operational logs
