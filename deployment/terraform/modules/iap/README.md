# IAP Module

This Terraform module configures Google Cloud Identity-Aware Proxy (IAP) for zero-trust access control to applications. IAP provides secure access to applications without requiring VPN connections by verifying user identity and context.

## Features

- **Zero-Trust Security**: Verify user identity before granting access
- **Context-Aware Access**: Consider device, location, and other factors
- **No VPN Required**: Secure access without traditional VPN infrastructure
- **Integration Ready**: Works with Cloud Run, GCE, and other services
- **Granular Controls**: Fine-grained access policies per application

## Usage

### Basic IAP Configuration

Since this module appears to be a placeholder or configuration-only module, it would typically be used in conjunction with other resources to enable IAP on services.

### With Cloud Run

```hcl
module "cloud_run" {
  source = "./modules/cloud-run"
  
  # ... other configuration
  
  # Configure for IAP
  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  
  invokers = {
    "iap-access" = [
      "user:admin@example.com",
      "group:developers@example.com"
    ]
  }
}

# Configure load balancer with IAP
resource "google_compute_backend_service" "default" {
  name = "cloud-run-backend"
  
  backend {
    group = google_compute_region_network_endpoint_group.cloudrun_neg.id
  }
  
  iap {
    oauth2_client_id     = var.oauth2_client_id
    oauth2_client_secret = var.oauth2_client_secret
  }
}
```

### IAP Access Policy

```hcl
resource "google_iap_web_iam_binding" "binding" {
  project = var.project_id
  role    = "roles/iap.httpsResourceAccessor"
  
  members = [
    "user:admin@example.com",
    "group:developers@example.com",
    "serviceAccount:app-service@project.iam.gserviceaccount.com"
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
    "iap.googleapis.com",
    "compute.googleapis.com"
  ]
}
```

### OAuth2 Setup

1. Create OAuth2 credentials in Google Cloud Console
2. Configure authorized domains
3. Set up consent screen

## IAM Roles

- `roles/iap.httpsResourceAccessor` - Access to HTTPS resources behind IAP
- `roles/iap.webServiceViewer` - View IAP web services
- `roles/iap.admin` - Manage IAP settings

## Example Scenarios

This module is referenced in:

- **scenario-9-cloud-run-iap**: Cloud Run service with Identity-Aware Proxy

## Security Benefits

1. **User Verification**: Every request verified against Google identity
2. **Context Analysis**: Device security, location, and behavior analysis
3. **Zero Trust**: No implicit trust based on network location
4. **Centralized Control**: Single point for access policy management

## Best Practices

1. **Least Privilege**: Grant minimal required access
2. **Group Management**: Use Google Groups for easier management
3. **Regular Audits**: Review access logs and permissions regularly
4. **Monitor Usage**: Set up alerts for unusual access patterns
