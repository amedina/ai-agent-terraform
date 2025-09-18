# Cache Module

This Terraform module provisions Google Cloud Memorystore for Redis instances, providing high-performance in-memory caching for applications requiring sub-millisecond data access and improved performance.

## Features

- **Managed Redis**: Fully managed Redis service with automatic patching and updates
- **High Availability**: Support for Standard HA tier with automatic failover
- **Scalable Memory**: Configurable memory sizes from 1GB to 300GB
- **Network Security**: VPC network authorization for secure access
- **Replica Support**: Configurable read replicas for improved read performance

## Resources Created

- `google_redis_instance` - Managed Redis instance with specified configuration

## Usage

### Basic Redis Cache

```hcl
module "cache" {
  source = "./modules/cache"
  
  project_id = "my-gcp-project"
  region     = "us-central1"
  name       = "app-cache"
  
  memory_size_gb = 1
  tier           = "BASIC"
}
```

### High Availability Redis

```hcl
module "cache" {
  source = "./modules/cache"
  
  project_id = "my-gcp-project"
  region     = "us-central1"
  name       = "ha-cache"
  
  tier           = "STANDARD_HA"
  memory_size_gb = 5
  replica_count  = 1
  
  authorized_network = "projects/my-project/global/networks/my-vpc"
}
```

### Production Redis Configuration

```hcl
module "cache" {
  source = "./modules/cache"
  
  project_id = "my-production-project"
  region     = "us-central1"
  name       = "prod-cache"
  
  tier           = "STANDARD_HA"
  memory_size_gb = 10
  replica_count  = 2
  
  authorized_network = "projects/my-project/global/networks/production-vpc"
}
```

### Application Integration

```hcl
# Cache module
module "cache" {
  source = "./modules/cache"
  
  project_id = var.project_id
  region     = var.region
  name       = "${var.app_name}-cache"
  
  tier               = "STANDARD_HA"
  memory_size_gb     = 5
  authorized_network = module.networking.network_self_link
}

# Cloud Run service using the cache
module "cloud_run" {
  source = "./modules/cloud-run"
  
  service_name = var.app_name
  image        = var.image_url
  region       = var.region
  
  environment_variables = {
    REDIS_HOST = module.cache.host
    REDIS_PORT = module.cache.port
  }
  
  depends_on = [module.cache]
}
```

## Variables

### Required Variables

| Name | Type | Description |
|------|------|-------------|
| `project_id` | `string` | GCP Project ID where the Redis instance will be created |
| `region` | `string` | GCP region for the Redis instance |
| `name` | `string` | Name of the Redis instance |

### Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `tier` | `string` | `"STANDARD_HA"` | Redis tier (BASIC or STANDARD_HA) |
| `memory_size_gb` | `number` | `1` | Memory size in GB (1-300) |
| `replica_count` | `number` | `1` | Number of read replicas (0-5, only for STANDARD_HA) |
| `authorized_network` | `string` | `null` | VPC network authorized to access the instance |

## Outputs

| Name | Description |
|------|-------------|
| `host` | The IP address of the Redis instance |
| `port` | The port number of the Redis instance (typically 6379) |

## Redis Tiers

### BASIC Tier
- **Use Case**: Development, testing, and non-critical workloads
- **Features**: Single node, no replication
- **Availability**: No SLA guarantee
- **Cost**: Lower cost option

### STANDARD_HA Tier
- **Use Case**: Production workloads requiring high availability
- **Features**: Primary node with replica, automatic failover
- **Availability**: 99.9% SLA
- **Cost**: Higher cost but production-ready

## Memory Size Guidelines

| Memory Size | Use Case | Typical Applications |
|-------------|----------|---------------------|
| 1-2 GB | Development/Testing | Small applications, session storage |
| 5-10 GB | Small Production | Web applications, API caching |
| 20-50 GB | Medium Production | Large web apps, analytics caching |
| 100+ GB | Large Production | Data-intensive applications, gaming |

## Network Configuration

### VPC Authorization
When `authorized_network` is specified, only resources within that VPC can access the Redis instance:

```hcl
module "networking" {
  source = "./modules/networking"
  # ... configuration
}

module "cache" {
  source = "./modules/cache"
  
  # ... other configuration
  authorized_network = module.networking.network_self_link
}
```

### Connection from Cloud Run
Cloud Run services need VPC connectivity to access Redis:

```hcl
module "vpc_connector" {
  source = "./modules/vpc-connector"
  # ... configuration
}

module "cloud_run" {
  source = "./modules/cloud-run"
  
  # ... other configuration
  vpc_connector = module.vpc_connector.connector_name
  
  environment_variables = {
    REDIS_HOST = module.cache.host
    REDIS_PORT = module.cache.port
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
    "redis.googleapis.com",
    "compute.googleapis.com"
  ]
}
```

### IAM Permissions

The service account or user running Terraform needs:

- `roles/redis.admin` - To manage Redis instances
- `roles/compute.networkViewer` - To validate network references

## Application Connection Examples

### Python (redis-py)

```python
import redis

# Connect to Redis
redis_client = redis.Redis(
    host='REDIS_HOST_FROM_OUTPUT',
    port=6379,
    decode_responses=True
)

# Basic operations
redis_client.set('key', 'value')
value = redis_client.get('key')
```

### Node.js (redis)

```javascript
const redis = require('redis');

const client = redis.createClient({
  host: process.env.REDIS_HOST,
  port: process.env.REDIS_PORT
});

client.on('connect', () => {
  console('Connected to Redis');
});

// Basic operations
await client.set('key', 'value');
const value = await client.get('key');
```

### Go (go-redis)

```go
import (
    "github.com/go-redis/redis/v8"
    "context"
)

rdb := redis.NewClient(&redis.Options{
    Addr: fmt.Sprintf("%s:%s", redisHost, redisPort),
})

ctx := context.Background()
err := rdb.Set(ctx, "key", "value", 0).Err()
val, err := rdb.Get(ctx, "key").Result()
```

## Monitoring and Maintenance

### Cloud Monitoring Metrics
- Memory usage percentage
- Connected clients
- Operations per second
- Cache hit ratio
- Network bytes in/out

### Best Practices
1. **Memory Management**: Monitor memory usage and set appropriate eviction policies
2. **Connection Pooling**: Use connection pooling in applications to optimize performance
3. **Key Expiration**: Set appropriate TTL values to prevent memory bloat
4. **Monitoring**: Set up alerts for memory usage, connections, and performance metrics

## Example Scenarios

This module is used in the following sample scenarios:

- **scenario-6-cloud-run-redis**: Demonstrates Cloud Run integration with Redis cache

## Limitations

- Redis instances cannot be resized down (only up)
- BASIC tier instances have no backup/restore functionality
- Network access is limited to the authorized VPC
- Maximum 5 read replicas for STANDARD_HA tier
- Regional availability may vary

## Troubleshooting

### Common Issues

1. **Connection timeouts**: Ensure VPC connectivity is properly configured
2. **Memory errors**: Monitor memory usage and consider increasing size
3. **Network access denied**: Verify `authorized_network` is correctly specified
4. **High latency**: Consider using read replicas or upgrading to STANDARD_HA

### Performance Tuning

1. **Memory Configuration**: Choose appropriate memory size based on data requirements
2. **Read Replicas**: Use replicas for read-heavy workloads
3. **Connection Pooling**: Implement connection pooling in applications
4. **Data Structure Optimization**: Use appropriate Redis data structures for your use case
