# Networking Module

This Terraform module provides secure, scalable network infrastructure for GCP resources including VPC networks, subnets, NAT gateways, and private service connections. It forms the foundation for secure connectivity across all infrastructure components.

## Features

- **Custom VPC**: Isolated network environments with custom subnets
- **Multi-Region Support**: Deploy subnets across multiple regions
- **NAT Gateway**: Outbound internet access for private resources
- **Private Service Access**: VPC peering for managed services
- **Firewall Rules**: Configurable security rules
- **Secondary IP Ranges**: Support for GKE and other services

## Resources Created

- `google_compute_network` - Custom VPC network
- `google_compute_subnetwork` - Regional subnets
- `google_compute_router` - Cloud Router for NAT
- `google_compute_router_nat` - NAT gateway configuration
- `google_compute_global_address` - Private service access IP ranges
- `google_service_networking_connection` - Private service connections

## Usage

### Basic VPC Network

```hcl
module "networking" {
  source = "./modules/networking"
  
  project_id = "my-gcp-project"
  vpc_name   = "main-vpc"
  
  subnets = {
    "us-central1" = {
      ip_cidr_range = "10.0.1.0/24"
      region        = "us-central1"
    }
  }
}
```

### Multi-Region Network with Private Services

```hcl
module "networking" {
  source = "./modules/networking"
  
  project_id = var.project_id
  vpc_name   = "production-vpc"
  
  subnets = {
    "us-central1" = {
      ip_cidr_range = "10.0.1.0/24"
      region        = "us-central1"
    }
    "us-east1" = {
      ip_cidr_range = "10.0.2.0/24"
      region        = "us-east1"
    }
  }
  
  enable_private_service_connect = true
  private_ip_range_name         = "private-services"
  private_ip_cidr              = "10.1.0.0/16"
}
```

### Network with NAT Gateway

```hcl
module "networking" {
  source = "./modules/networking"
  
  project_id = var.project_id
  vpc_name   = "secure-vpc"
  
  subnets = {
    "us-central1-private" = {
      ip_cidr_range = "10.0.1.0/24"
      region        = "us-central1"
    }
  }
  
  enable_nat_gateway = true
  nat_regions       = ["us-central1"]
}
```

## Variables

### Required Variables

| Name | Type | Description |
|------|------|-------------|
| `project_id` | `string` | GCP Project ID |
| `vpc_name` | `string` | Name of the VPC network |

### Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `subnets` | `map(object)` | `{}` | Map of subnet configurations |
| `enable_private_service_connect` | `bool` | `false` | Enable private service access |
| `private_ip_range_name` | `string` | `"private-services"` | Name for private IP range |
| `private_ip_cidr` | `string` | `"10.1.0.0/16"` | CIDR for private services |
| `enable_nat_gateway` | `bool` | `false` | Enable NAT gateway |
| `nat_regions` | `list(string)` | `[]` | Regions for NAT gateway |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | VPC network self-link |
| `subnet_ids` | Map of subnet self-links |
| `private_service_connect_enabled` | Whether private service access is enabled |
| `network_self_link` | Self-link of the VPC network |

## Subnet Configuration

Subnet objects support the following attributes:

```hcl
subnets = {
  "subnet-name" = {
    ip_cidr_range = "10.0.1.0/24"  # Required
    region        = "us-central1"   # Required
    description   = "Main subnet"   # Optional
    secondary_ip_ranges = [         # Optional
      {
        range_name    = "pods"
        ip_cidr_range = "10.1.0.0/16"
      }
    ]
  }
}
```

## IP Address Planning

### Recommended CIDR Ranges

| Environment | VPC CIDR | Subnet Size | Use Case |
|-------------|----------|-------------|----------|
| Development | 10.0.0.0/16 | /24 | Small workloads |
| Staging | 10.1.0.0/16 | /24 | Medium workloads |
| Production | 10.2.0.0/16 | /22 | Large workloads |

### Private Google Access

Enable private Google access for subnets to allow instances without external IPs to reach Google APIs:

```hcl
subnets = {
  "private-subnet" = {
    ip_cidr_range         = "10.0.1.0/24"
    region                = "us-central1"
    private_ip_google_access = true
  }
}
```

## Prerequisites

### APIs Required

```hcl
module "apis" {
  source = "./modules/apis"
  
  project_id = var.project_id
  services = [
    "compute.googleapis.com",
    "servicenetworking.googleapis.com"
  ]
}
```

## Integration Examples

### With Database Module

```hcl
module "networking" {
  source = "./modules/networking"
  # ... configuration
  enable_private_service_connect = true
}

module "database" {
  source = "./modules/database"
  # ... configuration
  private_network = module.networking.network_self_link
}
```

### With Cloud Run

```hcl
module "cloud_run" {
  source = "./modules/cloud-run"
  # ... configuration
  
  vpc_network_interface = {
    network    = module.networking.network_self_link
    subnetwork = module.networking.subnet_ids["us-central1"]
  }
}
```

## Security Considerations

### Firewall Rules

Create custom firewall rules for your applications:

```hcl
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal-${var.vpc_name}"
  network = module.networking.network_self_link
  
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
  
  source_ranges = ["10.0.0.0/16"]
}
```

### Network Segmentation

- Use separate subnets for different tiers (web, app, data)
- Implement least-privilege firewall rules
- Consider using multiple VPCs for strong isolation

## Example Scenarios

This module is used in multiple sample scenarios:

- **scenario-3-vpc-connector**: VPC connectivity for Cloud Run
- **scenario-4-private-gce-nat**: Private instances with NAT
- **scenario-5** through **scenario-12**: Various networking patterns

## Best Practices

1. **CIDR Planning**: Plan IP ranges to avoid conflicts
2. **Regional Distribution**: Use multiple regions for high availability
3. **Private by Default**: Use private subnets with NAT for security
4. **Service Mesh**: Consider Istio for advanced traffic management
5. **Monitoring**: Enable VPC Flow Logs for network observability

## Troubleshooting

### Common Issues

1. **CIDR Conflicts**: Ensure non-overlapping IP ranges
2. **Connectivity Issues**: Check firewall rules and routes
3. **Private Access**: Verify private Google access is enabled
4. **NAT Gateway**: Ensure NAT is configured for private instances

### Network Diagnostics

```bash
# Test connectivity
gcloud compute ssh INSTANCE_NAME --zone=ZONE

# Check routes
gcloud compute routes list --filter="network:NETWORK_NAME"

# Verify firewall rules
gcloud compute firewall-rules list --filter="network:NETWORK_NAME"
```
