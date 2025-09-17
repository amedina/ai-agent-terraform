# Secret Manager Module

This module creates and manages Google Cloud Secret Manager resources with proper IAM permissions and replication configuration.

## Purpose

- **Secure Secret Storage**: Centralized management of sensitive data like API keys, passwords, and certificates
- **IAM Integration**: Fine-grained access control for secrets
- **Replication Control**: Support for both automatic and user-managed replication
- **Version Management**: Automatic secret version creation and management

## Features

- Create multiple secrets with individual configurations
- Support for both automatic and user-managed replication
- IAM member management per secret
- Custom labels for organization and billing
- Secret version management
- Comprehensive outputs for integration

## Usage

```hcl
module "secrets" {
  source = "./modules/secret-manager"
  
  project_id = var.project_id
  
  labels = {
    environment = "production"
    team        = "platform"
  }
  
  # Optional: specify replication locations (if empty, uses automatic)
  replication_locations = ["us-central1", "us-east1"]
  
  secrets = [
    {
      name        = "database-password"
      secret_data = "super-secret-password"
      labels = {
        type = "database"
      }
      iam_members = [
        {
          role   = "roles/secretmanager.secretAccessor"
          member = "serviceAccount:my-app@project.iam.gserviceaccount.com"
        }
      ]
    },
    {
      name = "api-key"
      # secret_data can be omitted to create empty secret
      labels = {
        type = "api"
      }
      iam_members = [
        {
          role   = "roles/secretmanager.secretAccessor"
          member = "serviceAccount:api-service@project.iam.gserviceaccount.com"
        }
      ]
    }
  ]
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The GCP project ID | `string` | n/a | yes |
| labels | Labels to apply to all secrets | `map(string)` | `{}` | no |
| replication_locations | List of locations for user-managed replication. If empty, uses automatic replication | `list(string)` | `[]` | no |
| secrets | List of secrets to create | `list(object({...}))` | `[]` | no |

### Secret Object Structure

```
{
  name        = string           # Required: Secret name
  secret_data = string          # Optional: Secret data (if omitted, creates empty secret)
  labels      = map(string)     # Optional: Additional labels for this secret
  iam_members = list(object({   # Optional: IAM members for this secret
    role   = string
    member = string
  }))
}
```

## Outputs

| Name | Description |
|------|-------------|
| secret_ids | Map of secret names to their full resource IDs |
| secret_names | Map of secret names to their secret_id (short name) |
| secret_versions | Map of secret names to their latest version names |
| all_secrets | Complete information about all created secrets |

## IAM Roles

Common roles for Secret Manager:

- `roles/secretmanager.secretAccessor` - Read secret values
- `roles/secretmanager.secretVersionAdder` - Add new secret versions
- `roles/secretmanager.secretVersionManager` - Manage secret versions
- `roles/secretmanager.admin` - Full secret management

## Examples

### Basic Usage with Cloud Run

```hcl
module "app_secrets" {
  source     = "./modules/secret-manager"
  project_id = var.project_id
  
  secrets = [
    {
      name        = "app-database-url"
      secret_data = "postgresql://user:pass@host:5432/db"
      iam_members = [
        {
          role   = "roles/secretmanager.secretAccessor"
          member = "serviceAccount:${module.service_account.email}"
        }
      ]
    }
  ]
}

module "cloud_run" {
  source = "./modules/cloud-run"
  # ... other configuration
  
  env_vars = [
    {
      name = "DATABASE_URL"
      value_source = {
        secret_key_ref = {
          secret  = module.app_secrets.secret_names["app-database-url"]
          version = "latest"
        }
      }
    }
  ]
}
```

## Best Practices

1. **Least Privilege**: Grant minimal necessary permissions
2. **Environment Separation**: Use different secrets for different environments
3. **Rotation**: Regularly rotate sensitive secrets
4. **Labeling**: Use consistent labeling for organization
5. **Monitoring**: Enable audit logging for secret access

## Requirements

- Google Cloud Secret Manager API must be enabled
- Appropriate IAM permissions for the service account running Terraform
- Terraform >= 1.0
