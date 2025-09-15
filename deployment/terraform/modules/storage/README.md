# Storage Module

This Terraform module provisions Google Cloud Storage buckets with security controls, lifecycle management, and IAM
policies. It provides secure object storage for applications with configurable access controls and data management
policies.

## Features

- **Secure Storage**: Object storage with encryption and access controls
- **Lifecycle Management**: Automated data lifecycle policies
- **IAM Integration**: Fine-grained access control with IAM bindings
- **Public Access Prevention**: Configurable public access controls
- **Versioning**: Object versioning and retention policies
- **Multi-Region Support**: Regional and multi-regional bucket configurations

## Resources Created

- `google_storage_bucket` - Cloud Storage bucket with specified configuration
- `google_storage_bucket_iam_binding` - IAM access controls (optional)

## Usage

### Basic Storage Bucket

```hcl
module "storage" {
  source = "./modules/storage"

  project_id = "my-gcp-project"
  name       = "my-app-storage"
  location   = "US"
}
```

### Regional Bucket with Lifecycle Policy

```hcl
module "storage" {
  source = "./modules/storage"

  project_id = var.project_id
  name       = "app-data-storage"
  location   = "us-central1"

  lifecycle_age_days = 30  # Delete objects after 30 days

  labels = {
    environment = "production"
    team        = "backend"
  }
}
```

### Secure Bucket with IAM Controls

```hcl
module "storage" {
  source = "./modules/storage"

  project_id = var.project_id
  name       = "secure-app-storage"
  location   = "us-central1"

  public_access_prevention = "enforced"
  force_destroy            = false

  iam_members = [
    {
      role   = "roles/storage.objectViewer"
      member = "serviceAccount:${module.service_account.email}"
    },
    {
      role   = "roles/storage.objectCreator"
      member = "serviceAccount:${module.cloud_run_sa.email}"
    }
  ]
}
```

### Multi-Regional Bucket for Global Access

```hcl
module "storage" {
  source = "./modules/storage"

  project_id = var.project_id
  name       = "global-assets"
  location = "US"  # Multi-regional

  labels = {
    purpose = "static-assets"
    public  = "true"
  }

  iam_members = [
    {
      role   = "roles/storage.objectViewer"
      member = "allUsers"  # Public read access
    }
  ]
}
```

## Variables

### Required Variables

| Name         | Type     | Description                              |
|--------------|----------|------------------------------------------|
| `project_id` | `string` | GCP Project ID                           |
| `name`       | `string` | Name of the storage bucket               |
| `location`   | `string` | Bucket location (region or multi-region) |

### Optional Variables

| Name                       | Type           | Default      | Description                                     |
|----------------------------|----------------|--------------|-------------------------------------------------|
| `force_destroy`            | `bool`         | `true`       | Allow bucket deletion even if not empty         |
| `public_access_prevention` | `string`       | `"enforced"` | Public access prevention setting                |
| `labels`                   | `map(string)`  | `{}`         | Labels to apply to the bucket                   |
| `lifecycle_age_days`       | `number`       | `0`          | Auto-delete objects after N days (0 = disabled) |
| `iam_members`              | `list(object)` | `[]`         | IAM bindings for the bucket                     |

## Outputs

| Name          | Description                        |
|---------------|------------------------------------|
| `bucket_name` | Name of the created storage bucket |
| `bucket_url`  | URL of the storage bucket          |

## Location Options

### Regional Locations

- `us-central1`, `us-east1`, `us-west1`, `us-west2`
- `europe-west1`, `europe-west2`, `europe-west3`
- `asia-east1`, `asia-southeast1`, `asia-northeast1`

### Multi-Regional Locations

- `US` - United States multi-region
- `EU` - European Union multi-region
- `ASIA` - Asia multi-region

### Dual-Regional Locations

- `US-CENTRAL1+US-WEST1`
- `EUROPE-WEST1+EUROPE-WEST4`
- `ASIA-NORTHEAST1+ASIA-NORTHEAST2`

## Public Access Prevention

| Setting     | Description                      | Use Case                  |
|-------------|----------------------------------|---------------------------|
| `enforced`  | Prevent public access completely | Private application data  |
| `inherited` | Use organization policy          | Inherit from org settings |

## Storage Classes

Configure storage class for cost optimization:

```hcl
resource "google_storage_bucket" "bucket" {
  name     = var.name
  location = var.location

  storage_class = "STANDARD"  # STANDARD, NEARLINE, COLDLINE, ARCHIVE
}
```

## Lifecycle Management

### Age-Based Deletion

```hcl
module "storage" {
  source = "./modules/storage"
  # ... other configuration

  lifecycle_age_days = 90  # Delete after 90 days
}
```

### Advanced Lifecycle Rules

For complex lifecycle needs, extend the module or use additional resources:

```hcl
resource "google_storage_bucket" "bucket" {
  # ... configuration

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type = "Delete"
    }
  }
}
```

## IAM Roles for Cloud Storage

### Object-Level Permissions

- `roles/storage.objectViewer` - Read objects
- `roles/storage.objectCreator` - Create objects
- `roles/storage.objectAdmin` - Full control over objects

### Bucket-Level Permissions

- `roles/storage.admin` - Full control over buckets and objects
- `roles/storage.objectViewer` - List and read objects

## Usage with Other Modules

### With Cloud Run

```hcl
module "storage" {
  source = "./modules/storage"

  project_id = var.project_id
  name       = "app-storage"
  location   = "us-central1"

  iam_members = [
    {
      role   = "roles/storage.objectAdmin"
      member = "serviceAccount:${module.service_account.email}"
    }
  ]
}

module "cloud_run" {
  source = "./modules/cloud-run"

  # ... other configuration

  env = {
    STORAGE_BUCKET = module.storage.bucket_name
  }
}
```

### With AI/ML Workloads

```hcl
module "storage" {
  source = "./modules/storage"

  project_id = var.project_id
  name       = "ml-data-storage"
  location   = "us-central1"

  labels = {
    purpose = "ml-training-data"
    team    = "ai-ml"
  }

  iam_members = [
    {
      role   = "roles/storage.objectAdmin"
      member = "serviceAccount:${module.ai_service_account.email}"
    }
  ]
}
```

## Prerequisites

### APIs Required

```hcl
module "apis" {
  source = "./modules/apis"

  project_id = var.project_id
  services = [
    "storage-component.googleapis.com",
    "storage-api.googleapis.com"
  ]
}
```

## Security Best Practices

### Access Control

1. **Principle of Least Privilege**: Grant minimal required permissions
2. **Use Service Accounts**: Avoid user account access for applications
3. **Regular Audits**: Review bucket IAM policies regularly

### Data Protection

1. **Encryption**: All data encrypted at rest by default
2. **Versioning**: Enable object versioning for important data
3. **Backup Strategy**: Implement cross-region replication if needed

### Network Security

1. **VPC Service Controls**: Use VPC SC for sensitive data
2. **Signed URLs**: Use signed URLs for temporary access
3. **Audit Logging**: Enable Cloud Audit Logs

## Access Patterns

### Direct Application Access

```python
from google.cloud import storage

client = storage.Client()
bucket = client.bucket('bucket-name')
blob = bucket.blob('file-name')

# Upload
blob.upload_from_string('Hello, World!')

# Download
content = blob.download_as_string()
```

### Signed URLs for Temporary Access

```python
from google.cloud import storage
from datetime import datetime, timedelta

client = storage.Client()
bucket = client.bucket('bucket-name')
blob = bucket.blob('file-name')

# Generate signed URL valid for 1 hour
url = blob.generate_signed_url(
    version="v4",
    expiration=datetime.utcnow() + timedelta(hours=1),
    method="GET"
)
```

## Example Scenarios

This module is used in:

- **scenario-1-cloud-run-gcs**: Basic Cloud Run with Cloud Storage integration

## Monitoring and Cost Optimization

### Cloud Monitoring Metrics

- Storage usage and growth
- Request count and latency
- Egress bandwidth usage
- Storage class distribution

### Cost Optimization

1. **Choose Appropriate Location**: Regional vs multi-regional
2. **Lifecycle Policies**: Automatic transition to cheaper storage classes
3. **Request Optimization**: Minimize API calls
4. **Egress Monitoring**: Monitor data transfer costs

## Troubleshooting

### Common Issues

1. **Permission Denied**: Check IAM permissions and public access settings
2. **Bucket Already Exists**: Bucket names must be globally unique
3. **Lifecycle Errors**: Verify lifecycle rule syntax and conditions
4. **Public Access Blocked**: Check organization policies

### Debugging Commands

```bash
# List buckets
gsutil ls

# Check bucket IAM policy
gsutil iam get gs://BUCKET_NAME

# Test bucket access
gsutil ls gs://BUCKET_NAME

# Check bucket configuration
gsutil lifecycle get gs://BUCKET_NAME
```
