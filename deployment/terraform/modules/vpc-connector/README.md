# VPC Connector Module

This Terraform module provisions Google Cloud VPC Access connectors for serverless-to-VPC connectivity. VPC connectors enable Cloud Run, Cloud Functions, and App Engine services to access resources in a VPC network securely.

## Features

- **Serverless VPC Connectivity**: Connect serverless services to VPC networks
- **Secure Communication**: Private connectivity without exposing resources publicly
- **Auto-Scaling**: Automatic scaling based on traffic demands
- **Regional Deployment**: Deploy connectors in specific regions
- **Configurable Capacity**: Adjustable instance count for performance tuning

## Resources Created

- `google_vpc_access_connector` - VPC Access connector with specified configuration

## Usage

### Basic VPC Connector

```hcl
module "vpc_connector" {
  source = "./modules/vpc-connector"
  
  project_id = "my-gcp-project"
  region     = "us-central1"
  name       = "serverless-connector"
  network    = module.networking.network_self_link
  subnetwork = module.networking.subnet_ids["us-central1"]
}
```

### VPC Connector with Custom IP Range

```hcl
module "vpc_connector" {
  source = "./modules/vpc-connector"
  
  project_id    = var.project_id
  region        = var.region
  name          = "app-connector"
  network       = module.networking.network_self_link
  subnetwork    = module.networking.subnet_ids[var.region]
  ip_cidr_range = "10.8.0.0/28"
}
```

### High-Capacity VPC Connector

```hcl
module "vpc_connector" {
  source = "./modules/vpc-connector"
  
  project_id = var.project_id
  region     = var.region
  name       = "high-capacity-connector"
  network    = module.networking.network_self_link
  subnetwork = module.networking.subnet_ids[var.region]
  
  min_instances = 5
  max_instances = 20
}
```

## Variables

### Required Variables

| Name | Type | Description |
|------|------|-------------|
| `project_id` | `string` | GCP Project ID |
| `region` | `string` | GCP region for the VPC connector |
| `name` | `string` | Name of the VPC connector |
| `network` | `string` | VPC network self-link |
| `subnetwork` | `string` | Subnetwork self-link |

### Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `ip_cidr_range` | `string` | `null` | IP CIDR range for the connector (auto-assigned if null) |
| `min_instances` | `number` | `2` | Minimum number of instances |
| `max_instances` | `number` | `10` | Maximum number of instances |

## Outputs

| Name | Description |
|------|-------------|
| `id` | ID of the VPC connector |
| `name` | Name of the VPC connector |

## IP Range Requirements

### Automatic Assignment
When `ip_cidr_range` is not specified, Google Cloud automatically assigns a `/28` subnet:

```hcl
module "vpc_connector" {
  # ... other configuration
  # ip_cidr_range is automatically assigned
}
```

### Manual Assignment
Specify a `/28` subnet that doesn't conflict with existing subnets:

```hcl
module "vpc_connector" {
  # ... other configuration
  ip_cidr_range = "10.8.0.0/28"  # Must be /28
}
```

## Scaling Configuration

### Instance Scaling
VPC connectors auto-scale based on traffic:

| Configuration | Min Instances | Max Instances | Use Case |
|---------------|---------------|---------------|----------|
| Low Traffic | 2 | 3 | Development/Testing |
| Medium Traffic | 2 | 10 | Production |
| High Traffic | 5 | 20 | High-scale production |

### Performance Considerations
- Each instance handles ~200-400 concurrent connections
- Higher instance counts provide better performance and availability
- Scaling occurs automatically based on traffic patterns

## Usage with Cloud Run

### Direct Integration

```hcl
module "vpc_connector" {
  source = "./modules/vpc-connector"
  # ... configuration
}

module "cloud_run" {
  source = "./modules/cloud-run"
  
  # ... other configuration
  
  vpc_egress = "PRIVATE_RANGES_ONLY"
  # Note: VPC connector is referenced by name in Cloud Run console or gcloud
}
```

### Environment Variable Pattern

```hcl
module "cloud_run" {
  source = "./modules/cloud-run"
  
  # ... other configuration
  
  env = {
    DB_HOST    = module.database.private_ip
    REDIS_HOST = module.cache.host
  }
  
  vpc_egress = "PRIVATE_RANGES_ONLY"
}
```

## Prerequisites

### APIs Required

```hcl
module "apis" {
  source = "./modules/apis"
  
  project_id = var.project_id
  services = [
    "vpcaccess.googleapis.com",
    "compute.googleapis.com"
  ]
}
```

### Network Prerequisites

Ensure VPC and subnets are created before the connector:

```hcl
module "networking" {
  source = "./modules/networking"
  # ... configuration
}

module "vpc_connector" {
  source = "./modules/vpc-connector"
  
  # ... configuration
  network    = module.networking.network_self_link
  subnetwork = module.networking.subnet_ids[var.region]
  
  depends_on = [module.networking]
}
```

## Integration Examples

### Cloud Run with Database

```hcl
# Network infrastructure
module "networking" {
  source = "./modules/networking"
  # ... configuration
}

# VPC connector for serverless access
module "vpc_connector" {
  source = "./modules/vpc-connector"
  
  project_id = var.project_id
  region     = var.region
  name       = "db-connector"
  network    = module.networking.network_self_link
  subnetwork = module.networking.subnet_ids[var.region]
}

# Private database
module "database" {
  source = "./modules/database"
  
  # ... configuration
  private_network = module.networking.network_self_link
}

# Cloud Run service
module "cloud_run" {
  source = "./modules/cloud-run"
  
  # ... other configuration
  
  env = {
    DB_HOST = module.database.private_ip
  }
  
  vpc_egress = "PRIVATE_RANGES_ONLY"
}
```

### Multi-Service Architecture

```hcl
module "vpc_connector" {
  source = "./modules/vpc-connector"
  
  project_id = var.project_id
  region     = var.region
  name       = "services-connector"
  network    = module.networking.network_self_link
  subnetwork = module.networking.subnet_ids[var.region]
  
  min_instances = 3
  max_instances = 15
}

# Multiple Cloud Run services can use the same connector
module "frontend_service" {
  source = "./modules/cloud-run"
  # ... configuration using vpc_connector
}

module "backend_service" {
  source = "./modules/cloud-run"
  # ... configuration using vpc_connector
}
```

## Security Considerations

### Network Isolation
VPC connectors provide secure connectivity without exposing internal resources:

1. **Private Resources**: Database and cache instances remain private
2. **Controlled Access**: Only authorized serverless services can access VPC resources
3. **No Public IPs**: Internal communication doesn't require public IP addresses

### Firewall Rules
Configure appropriate firewall rules for connector traffic:

```hcl
resource "google_compute_firewall" "vpc_connector" {
  name    = "allow-vpc-connector"
  network = module.networking.network_self_link
  
  allow {
    protocol = "tcp"
    ports    = ["5432", "6379"]  # Database and Redis ports
  }
  
  source_ranges = [module.vpc_connector.ip_cidr_range]
  target_tags   = ["database", "cache"]
}
```

## Example Scenarios

This module is used in:

- **scenario-3-vpc-connector**: Cloud Run with VPC connectivity demonstration

## Cost Considerations

### Pricing Factors
- Per-connector hourly charge
- Data processing charges for traffic
- Instance scaling affects cost

### Cost Optimization
1. **Right-size Instances**: Use appropriate min/max instance counts
2. **Regional Deployment**: Deploy connectors close to resources
3. **Traffic Monitoring**: Monitor and optimize data processing usage

## Troubleshooting

### Common Issues

1. **Connection Timeouts**: Verify firewall rules allow connector traffic
2. **IP Range Conflicts**: Ensure connector CIDR doesn't overlap with existing subnets
3. **Scaling Issues**: Monitor instance scaling and adjust limits if needed
4. **Permission Errors**: Verify VPC Access API is enabled and IAM permissions are correct

### Debugging Steps

```bash
# List VPC connectors
gcloud compute networks vpc-access connectors list --region=REGION

# Check connector status
gcloud compute networks vpc-access connectors describe CONNECTOR_NAME --region=REGION

# View connector logs
gcloud logging read "resource.type=\"vpc_access_connector\""

# Test connectivity from Cloud Run
# Add temporary test endpoint in your Cloud Run service to verify connectivity
```

### Network Diagnostics

```bash
# Check subnet configuration
gcloud compute networks subnets describe SUBNET_NAME --region=REGION

# Verify firewall rules
gcloud compute firewall-rules list --filter="network:NETWORK_NAME"

# Check routes
gcloud compute routes list --filter="network:NETWORK_NAME"
```

## Best Practices

1. **One Connector Per Region**: Create separate connectors for each region
2. **Appropriate Sizing**: Size instances based on expected traffic
3. **Network Planning**: Plan IP ranges to avoid conflicts
4. **Security**: Use least-privilege firewall rules
5. **Monitoring**: Set up monitoring for connector usage and performance
