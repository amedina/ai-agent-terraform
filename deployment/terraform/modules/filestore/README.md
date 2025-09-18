# Filestore Module

This Terraform module provisions Google Cloud Filestore instances for high-performance NFS file systems. Filestore provides POSIX-compliant shared storage that can be mounted by multiple Compute Engine instances or Cloud Run services.

## Features

- **NFS File System**: POSIX-compliant shared file system
- **High Performance**: Low-latency, high-throughput storage
- **Scalable**: Up to 100TB+ capacity with configurable performance tiers
- **Network Access**: VPC-based access with IP restrictions
- **Automatic Backups**: Scheduled backups and snapshots

## Resources Created

- `google_filestore_instance` - Managed NFS instance with specified configuration

## Usage

### Basic Filestore Instance

```hcl
module "filestore" {
  source = "./modules/filestore"
  
  project_id        = "my-gcp-project"
  location          = "us-central1"
  name              = "shared-storage"
  tier              = "BASIC_SSD"
  capacity_gb       = 1024
  network           = module.networking.network_self_link
  reserved_ip_range = "10.0.1.0/24"
}
```

### High Performance Filestore

```hcl
module "filestore" {
  source = "./modules/filestore"
  
  project_id        = var.project_id
  location          = var.region
  name              = "high-perf-storage"
  tier              = "HIGH_SCALE_SSD"
  capacity_gb       = 10240  # 10TB
  share_name        = "data"
  network           = module.networking.network_self_link
  reserved_ip_range = "192.168.100.0/24"
}
```

## Variables

### Required Variables

| Name | Type | Description |
|------|------|-------------|
| `project_id` | `string` | GCP Project ID |
| `location` | `string` | Zone or region for the Filestore instance |
| `name` | `string` | Name of the Filestore instance |
| `network` | `string` | VPC network self-link |
| `reserved_ip_range` | `string` | CIDR range for Filestore IP allocation |

### Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `tier` | `string` | `"BASIC_SSD"` | Performance tier |
| `capacity_gb` | `number` | `1024` | Storage capacity in GB |
| `share_name` | `string` | `"share"` | Name of the NFS share |

## Outputs

| Name | Description |
|------|-------------|
| `ip_addresses` | List of IP addresses for the Filestore instance |
| `mount_ip` | Primary IP address for mounting |
| `share_name` | Name of the NFS share |

## Performance Tiers

| Tier | Capacity Range | Performance | Use Case |
|------|----------------|-------------|----------|
| `BASIC_HDD` | 1TB - 63.9TB | Up to 180 MB/s | Archive, backup |
| `BASIC_SSD` | 2.5TB - 63.9TB | Up to 480 MB/s | General purpose |
| `HIGH_SCALE_SSD` | 10TB - 100TB+ | Up to 1.2 GB/s | High performance |

## Mounting Instructions

### From Compute Engine

```bash
# Create mount point
sudo mkdir -p /mnt/filestore

# Mount the share
sudo mount -t nfs MOUNT_IP:/SHARE_NAME /mnt/filestore

# Add to /etc/fstab for persistent mounting
echo "MOUNT_IP:/SHARE_NAME /mnt/filestore nfs defaults 0 0" | sudo tee -a /etc/fstab
```

### From Cloud Run

Add volume and mount configuration:

```hcl
module "cloud_run" {
  source = "./modules/cloud-run"
  
  # ... other configuration
  
  volumes = [
    {
      name = "filestore-vol"
      type = "nfs"
      nfs = {
        server = module.filestore.mount_ip
        path   = "/${module.filestore.share_name}"
      }
    }
  ]
  
  volume_mounts = [
    {
      name       = "filestore-vol"
      mount_path = "/shared-data"
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
    "file.googleapis.com"
  ]
}
```

## Example Scenarios

This module is used in:

- **scenario-8-cloud-run-filestore**: Cloud Run with shared file system

## Best Practices

1. **Network Planning**: Ensure IP range doesn't conflict with existing subnets
2. **Performance Sizing**: Choose appropriate tier based on throughput needs
3. **Security**: Restrict network access to required resources only
4. **Backup Strategy**: Implement regular snapshots for data protection
