# Service Account Module

This Terraform module creates and manages Google Cloud service accounts with least-privilege IAM roles. Service accounts provide secure, programmatic access to Google Cloud resources without requiring user credentials.

## Features

- **Least Privilege**: Create service accounts with minimal required permissions
- **Project-Level Roles**: Assign IAM roles at the project level
- **Key Management**: Optional service account key generation
- **Multiple Roles**: Support for multiple IAM role assignments
- **Security Best Practices**: Following Google Cloud security recommendations

## Resources Created

- `google_service_account` - Service account with specified configuration
- `google_project_iam_member` - Project-level IAM role assignments
- `google_service_account_iam_member` - Service account-level permissions (optional)

## Usage

### Basic Service Account

```hcl
module "service_account" {
  source = "./modules/service-account"
  
  project_id   = "my-gcp-project"
  account_id   = "app-service-account"
  display_name = "Application Service Account"
  description  = "Service account for my application"
}
```

### Service Account with IAM Roles

```hcl
module "service_account" {
  source = "./modules/service-account"
  
  project_id   = var.project_id
  account_id   = "cloud-run-sa"
  display_name = "Cloud Run Service Account"
  
  project_roles = [
    "roles/cloudsql.client",
    "roles/storage.objectViewer",
    "roles/secretmanager.secretAccessor"
  ]
}
```

### Service Account for AI/ML Workloads

```hcl
module "service_account" {
  source = "./modules/service-account"
  
  project_id   = var.project_id
  account_id   = "ai-workload-sa"
  display_name = "AI/ML Workload Service Account"
  
  project_roles = [
    "roles/aiplatform.user",
    "roles/storage.objectAdmin",
    "roles/bigquery.dataViewer"
  ]
}
```

### Database Service Account

```hcl
module "service_account" {
  source = "./modules/service-account"
  
  project_id   = var.project_id
  account_id   = "database-sa"
  display_name = "Database Service Account"
  
  project_roles = [
    "roles/cloudsql.client",
    "roles/cloudsql.instanceUser"
  ]
}
```

## Variables

### Required Variables

| Name | Type | Description |
|------|------|-------------|
| `project_id` | `string` | GCP Project ID |
| `account_id` | `string` | Service account ID (without @domain) |

### Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `display_name` | `string` | `null` | Human-readable display name |
| `description` | `string` | `null` | Description of the service account |
| `project_roles` | `list(string)` | `[]` | List of project-level IAM roles |
| `disabled` | `bool` | `false` | Whether the service account is disabled |

## Outputs

| Name | Description |
|------|-------------|
| `email` | Service account email address |
| `name` | Service account resource name |
| `unique_id` | Unique ID of the service account |

## Common IAM Roles

### Compute & Networking
- `roles/compute.instanceAdmin.v1` - Manage compute instances
- `roles/compute.networkUser` - Use VPC networks
- `roles/compute.securityAdmin` - Manage firewall rules

### Storage & Database
- `roles/storage.objectAdmin` - Full control over Cloud Storage objects
- `roles/storage.objectViewer` - Read-only access to Cloud Storage objects
- `roles/cloudsql.client` - Connect to Cloud SQL instances
- `roles/cloudsql.instanceUser` - Use Cloud SQL instances

### AI/ML
- `roles/aiplatform.user` - Use Vertex AI services
- `roles/ml.admin` - Full access to ML services
- `roles/bigquery.dataViewer` - Read BigQuery data

### Security & Monitoring
- `roles/secretmanager.secretAccessor` - Access secrets
- `roles/monitoring.metricWriter` - Write monitoring metrics
- `roles/logging.logWriter` - Write logs

### Serverless
- `roles/run.invoker` - Invoke Cloud Run services
- `roles/cloudfunctions.invoker` - Invoke Cloud Functions

## Usage with Other Modules

### With Cloud Run

```hcl
module "service_account" {
  source = "./modules/service-account"
  
  project_id   = var.project_id
  account_id   = "cloud-run-sa"
  display_name = "Cloud Run Service Account"
  
  project_roles = [
    "roles/cloudsql.client",
    "roles/storage.objectViewer"
  ]
}

module "cloud_run" {
  source = "./modules/cloud-run"
  
  # ... other configuration
  service_account = module.service_account.email
}
```

### With Compute Engine

```hcl
module "service_account" {
  source = "./modules/service-account"
  
  project_id   = var.project_id
  account_id   = "gce-sa"
  display_name = "GCE Service Account"
  
  project_roles = [
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter"
  ]
}

resource "google_compute_instance" "vm" {
  # ... other configuration
  
  service_account {
    email  = module.service_account.email
    scopes = ["cloud-platform"]
  }
}
```

## Security Best Practices

### Principle of Least Privilege
Only grant the minimum permissions required:

```hcl
# Good: Specific permissions
project_roles = [
  "roles/storage.objectViewer",  # Only read access to specific bucket
  "roles/cloudsql.client"        # Only connect to database
]

# Avoid: Overly broad permissions
project_roles = [
  "roles/owner",     # Too broad
  "roles/editor"     # Too broad
]
```

### Service Account Naming
Use descriptive names that indicate purpose:

```hcl
account_id = "cloud-run-backend-sa"     # Good
account_id = "my-service-account"       # Avoid
```

### Regular Audits
Periodically review and remove unused service accounts:

```bash
# List service accounts
gcloud iam service-accounts list

# Check service account usage
gcloud logging read "protoPayload.authenticationInfo.principalEmail:SA_EMAIL"
```

## Prerequisites

### APIs Required

```hcl
module "apis" {
  source = "./modules/apis"
  
  project_id = var.project_id
  services = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}
```

### IAM Permissions

The user or service account creating these resources needs:

- `roles/iam.serviceAccountAdmin` - Create and manage service accounts
- `roles/resourcemanager.projectIamAdmin` - Assign project-level roles

## Key Management

### Avoid Service Account Keys
When possible, use workload identity or other keyless authentication:

```hcl
# Preferred: Use workload identity
module "service_account" {
  source = "./modules/service-account"
  # ... configuration without keys
}

# Avoid: Creating service account keys
resource "google_service_account_key" "key" {
  service_account_id = module.service_account.name
}
```

### Key Rotation
If keys are necessary, implement regular rotation:

```bash
# Create new key
gcloud iam service-accounts keys create key.json \
  --iam-account=SA_EMAIL

# Delete old key
gcloud iam service-accounts keys delete KEY_ID \
  --iam-account=SA_EMAIL
```

## Example Scenarios

Service accounts are used across all sample scenarios:

- **All scenarios**: Each demonstrates proper service account usage for different services

## Monitoring and Auditing

### Cloud Logging
Monitor service account usage:

```bash
# View service account activity
gcloud logging read "protoPayload.authenticationInfo.principalEmail:SA_EMAIL" \
  --limit=50 --format="table(timestamp,protoPayload.methodName)"
```

### IAM Recommender
Use IAM Recommender to optimize permissions:

```bash
# Get recommendations
gcloud recommender recommendations list \
  --project=PROJECT_ID \
  --recommender=google.iam.policy.Recommender \
  --location=global
```

## Troubleshooting

### Common Issues

1. **Permission Denied**: Verify the service account has required roles
2. **Service Account Not Found**: Check account_id format and existence
3. **Role Assignment Fails**: Ensure proper IAM permissions for Terraform
4. **Authentication Issues**: Verify service account is properly configured

### Debugging Commands

```bash
# List service account roles
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:SA_EMAIL"

# Test service account permissions
gcloud auth activate-service-account SA_EMAIL --key-file=key.json
gcloud auth list
```
