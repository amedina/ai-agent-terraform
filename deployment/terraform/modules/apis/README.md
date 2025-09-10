# APIs Module

This Terraform module manages the enablement of Google Cloud APIs for your project. It provides a centralized way to enable multiple APIs required by your infrastructure components with proper dependency management.

## Features

- **Dynamic API Enablement**: Enable multiple APIs using a single module call
- **Dependency Management**: Ensures APIs are enabled before dependent resources are created
- **Configurable Cleanup**: Optional API disabling on resource destruction
- **Validation**: Built-in validation for API service names

## Resources Created

- `google_project_service` - Enables specified Google Cloud APIs for the project

## Usage

### Basic API Enablement

```hcl
module "apis" {
  source = "./modules/apis"
  
  project_id = "my-gcp-project"
  services = [
    "compute.googleapis.com",
    "run.googleapis.com",
    "sqladmin.googleapis.com"
  ]
}
```

### AI/ML Stack APIs

```hcl
module "apis" {
  source = "./modules/apis"
  
  project_id = "my-ai-project"
  services = [
    "aiplatform.googleapis.com",
    "run.googleapis.com",
    "storage-component.googleapis.com",
    "storage-api.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com"
  ]
  
  disable_on_destroy = false
}
```

### Full Infrastructure Stack

```hcl
module "apis" {
  source = "./modules/apis"
  
  project_id = "my-project"
  services = [
    # Compute & Networking
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "vpcaccess.googleapis.com",
    
    # Serverless
    "run.googleapis.com",
    "cloudfunctions.googleapis.com",
    
    # Storage & Database
    "storage-component.googleapis.com",
    "storage-api.googleapis.com",
    "sqladmin.googleapis.com",
    "redis.googleapis.com",
    "file.googleapis.com",
    
    # AI/ML
    "aiplatform.googleapis.com",
    
    # Monitoring & Logging
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    
    # Security
    "iap.googleapis.com",
    
    # Build & Deploy
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com"
  ]
  
  disable_on_destroy = false
}
```

## Variables

### Required Variables

| Name | Type | Description |
|------|------|-------------|
| `project_id` | `string` | GCP Project ID where APIs will be enabled |

### Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `services` | `list(string)` | `[]` | List of Google Cloud APIs to enable |
| `disable_on_destroy` | `bool` | `false` | Whether to disable APIs when the resource is destroyed |

## Outputs

| Name | Description |
|------|-------------|
| `enabled_services` | List of enabled API service names |

## Common API Services

Here are commonly used Google Cloud APIs for different use cases:

### Essential APIs
- `compute.googleapis.com` - Compute Engine API
- `iam.googleapis.com` - Identity and Access Management API
- `cloudresourcemanager.googleapis.com` - Resource Manager API

### Networking
- `servicenetworking.googleapis.com` - Service Networking API
- `dns.googleapis.com` - Cloud DNS API
- `vpcaccess.googleapis.com` - VPC Access API

### Serverless
- `run.googleapis.com` - Cloud Run API
- `cloudfunctions.googleapis.com` - Cloud Functions API

### Storage & Database
- `storage-component.googleapis.com` - Cloud Storage API
- `storage-api.googleapis.com` - Cloud Storage JSON API
- `sqladmin.googleapis.com` - Cloud SQL Admin API
- `redis.googleapis.com` - Memorystore for Redis API
- `file.googleapis.com` - Cloud Filestore API

### AI/ML
- `aiplatform.googleapis.com` - Vertex AI API
- `ml.googleapis.com` - Machine Learning API

### Monitoring & Security
- `logging.googleapis.com` - Cloud Logging API
- `monitoring.googleapis.com` - Cloud Monitoring API
- `iap.googleapis.com` - Identity-Aware Proxy API

### Build & Deploy
- `cloudbuild.googleapis.com` - Cloud Build API
- `artifactregistry.googleapis.com` - Artifact Registry API

## Best Practices

### API Dependencies
Always enable APIs before creating dependent resources. This module should typically be one of the first modules called in your Terraform configuration.

```hcl
# Enable APIs first
module "apis" {
  source = "./modules/apis"
  # ... configuration
}

# Then create resources that depend on those APIs
module "cloud_run" {
  source = "./modules/cloud-run"
  depends_on = [module.apis]
  # ... configuration
}
```

### Disable on Destroy
Set `disable_on_destroy = false` (default) for production environments to prevent accidental API disabling, which could affect other resources or projects.

```hcl
module "apis" {
  source = "./modules/apis"
  
  project_id = var.project_id
  services   = var.required_apis
  
  # Recommended for production
  disable_on_destroy = false
}
```

### API Batching
Enable all required APIs in a single module call rather than multiple separate calls to improve performance and reduce complexity.

## Prerequisites

### IAM Permissions

The service account or user running Terraform needs the following roles:

- `roles/serviceusage.serviceUsageAdmin` - To enable and disable APIs
- `roles/browser` - To view project resources

### Project Setup

Ensure your Google Cloud project has:
- Billing enabled
- The Service Usage API enabled (this is typically enabled by default)

## Module Dependencies

This module is typically used as a dependency for other modules in this repository:

- **ai-ml**: Requires `aiplatform.googleapis.com`
- **cloud-run**: Requires `run.googleapis.com`
- **database**: Requires `sqladmin.googleapis.com`
- **cache**: Requires `redis.googleapis.com`
- **storage**: Requires `storage-component.googleapis.com`
- **networking**: Requires `compute.googleapis.com`, `servicenetworking.googleapis.com`
- **vpc-connector**: Requires `vpcaccess.googleapis.com`

## Troubleshooting

### Common Issues

1. **Insufficient permissions**: Ensure the Terraform service account has `roles/serviceusage.serviceUsageAdmin`
2. **Billing not enabled**: Some APIs require billing to be enabled on the project
3. **API not available in region**: Some APIs may not be available in all regions
4. **Quota exceeded**: Check API quotas and limits in the Google Cloud Console

### Validation

After applying, you can verify enabled APIs using:

```bash
gcloud services list --enabled --project=YOUR_PROJECT_ID
```

### Monitoring

Monitor API usage and quotas through:
- Google Cloud Console > APIs & Services > Dashboard
- Google Cloud Console > APIs & Services > Quotas

## Example Scenarios

This module is used in all sample scenarios in this repository:

- **scenario-1** through **scenario-12**: Each demonstrates different API requirements for various infrastructure patterns

The module ensures all required APIs are enabled before other resources are created, preventing common deployment failures.
