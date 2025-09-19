# Cloud Run Module

This Terraform module provisions Google Cloud Run v2 services for serverless container deployment. It provides a fully managed platform for deploying containerized applications with automatic scaling, built-in security, and pay-per-use pricing.

## Features

- **Serverless Containers**: Deploy containerized applications without managing infrastructure
- **Auto Scaling**: Automatic scaling from 0 to configured maximum instances
- **VPC Connectivity**: Support for VPC network interfaces and egress control
- **Volume Mounting**: Support for secrets and GCS volumes
- **IAM Integration**: Configurable invoker permissions
- **Resource Management**: CPU and memory limits with idle scaling
- **Environment Variables**: Dynamic environment variable configuration

## Resources Created

- `google_cloud_run_v2_service` - Cloud Run service with specified configuration
- `google_cloud_run_v2_service_iam_binding` - IAM bindings for service invokers

## Usage

### Basic Cloud Run Service

```hcl
module "cloud_run" {
  source = "./modules/cloud-run"
  
  project_id = "my-gcp-project"
  region     = "us-central1"
  name       = "my-app"
  image      = "gcr.io/my-project/my-app:latest"
  
  resource_limits = {
    cpu    = "1"
    memory = "512Mi"
  }
}
```

### AI Application with Environment Variables

```hcl
module "cloud_run" {
  source = "./modules/cloud-run"
  
  project_id = var.project_id
  region     = var.region
  name       = "ai-chat-app"
  image      = "gcr.io/my-project/ai-chat:v1.0"
  
  env = {
    MODEL_NAME     = "gemini-pro"
    API_ENDPOINT   = "https://api.example.com"
    ENVIRONMENT    = "production"
  }
  
  resource_limits = {
    cpu    = "2"
    memory = "2Gi"
  }
  
  min_instances = 1
  max_instances = 10
}
```

### Service with VPC Connectivity

```hcl
module "cloud_run" {
  source = "./modules/cloud-run"
  
  project_id = var.project_id
  region     = var.region
  name       = "backend-service"
  image      = var.image_url
  
  # VPC network interface for direct VPC access
  vpc_network_interface = {
    network    = "projects/my-project/global/networks/my-vpc"
    subnetwork = "projects/my-project/regions/us-central1/subnetworks/my-subnet"
  }
  
  vpc_egress = "PRIVATE_RANGES_ONLY"
  
  env = {
    DATABASE_HOST = module.database.private_ip
    REDIS_HOST    = module.cache.host
  }
  
  service_account = module.service_account.email
}
```

### Service with Volumes and Secrets
```hcl
module "cloud_run" {
  source = "./modules/cloud-run"
  
  project_id = var.project_id
  region     = var.region
  name       = "secure-app"
  image      = var.image_url
  
  volumes = [
    {
      name        = "secrets-vol"
      type        = "secret"
      secret_name = "app-secrets"
    }
  ]
  
  volume_mounts = [
    {
      name       = "secrets-vol"
      mount_path = "/etc/secrets"
    }
  ]
  
  invokers = {
    "public-access" = ["allUsers"]
    "service-access" = [
      "serviceAccount:my-service@my-project.iam.gserviceaccount.com"
    ]
  }
}
```

### High Performance Configuration

```hcl
module "cloud_run" {
  source = "./modules/cloud-run"
  
  project_id = var.project_id
  region     = var.region
  name       = "high-perf-app"
  image      = var.image_url
  
  min_instances = 5
  max_instances = 100
  timeout_seconds = 900
  
  resource_limits = {
    cpu    = "4"
    memory = "8Gi"
  }
  
  cpu_idle = false
  startup_cpu_boost = true
  
  service_account = module.service_account.email
}
```

## Variables

### Required Variables

| Name | Type | Description |
|------|------|-------------|
| `project_id` | `string` | GCP Project ID where the Cloud Run service will be created |
| `region` | `string` | GCP region for the Cloud Run service |
| `name` | `string` | Name of the Cloud Run service |
| `image` | `string` | Container image URL (e.g., gcr.io/project/image:tag) |

### Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `service_account` | `string` | `null` | Service account email for the service |
| `min_instances` | `number` | `0` | Minimum number of instances |
| `max_instances` | `number` | `3` | Maximum number of instances |
| `timeout_seconds` | `number` | `300` | Request timeout in seconds (max 3600) |
| `ingress` | `string` | `"INGRESS_TRAFFIC_ALL"` | Ingress traffic control |
| `vpc_egress` | `string` | `"PRIVATE_RANGES_ONLY"` | VPC egress setting |
| `vpc_network_interface` | `object` | `null` | VPC network interface configuration |
| `env` | `map(string)` | `{}` | Environment variables |
| `resource_limits` | `map(string)` | `{cpu="1", memory="512Mi"}` | Resource limits |
| `cpu_idle` | `bool` | `true` | Whether to allow CPU throttling when idle |
| `startup_cpu_boost` | `bool` | `true` | Whether to boost CPU during startup |
| `volumes` | `list(object)` | `[]` | Volume configurations |
| `volume_mounts` | `list(object)` | `[]` | Volume mount configurations |
| `invokers` | `map(list(string))` | `{}` | IAM bindings for service invokers |

## Outputs

| Name | Description |
|------|-------------|
| `service_name` | The name of the deployed Cloud Run service |
| `uri` | The URI of the deployed Cloud Run service |

## Ingress Options

| Value | Description | Use Case |
|-------|-------------|----------|
| `INGRESS_TRAFFIC_ALL` | Accept all traffic | Public web applications |
| `INGRESS_TRAFFIC_INTERNAL_ONLY` | Internal traffic only | Internal services |
| `INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER` | Load balancer traffic | Load balanced applications |

## VPC Egress Options

| Value | Description |
|-------|-------------|
| `ALL_TRAFFIC` | Route all egress through VPC |
| `PRIVATE_RANGES_ONLY` | Route only private ranges through VPC |

## Resource Limits

### CPU Limits
- **Fractional values**: `"0.25"`, `"0.5"`, `"1"`, `"2"`, `"4"`, `"6"`, `"8"`
- **Integer values**: `"1"`, `"2"`, `"4"`, `"6"`, `"8"`

### Memory Limits
- **Format**: Use Mi (mebibytes) or Gi (gibibytes)
- **Examples**: `"128Mi"`, `"512Mi"`, `"1Gi"`, `"2Gi"`, `"8Gi"`
- **Range**: 128Mi to 32Gi

## Volume Types

### Secret Volumes
Mount Google Cloud Secret Manager secrets as files:

```hcl
volumes = [
  {
    name        = "app-secrets"
    type        = "secret"
    secret_name = "my-secret"
  }
]
```


### GCS Volumes
Mount a Cloud Storage bucket directly into the container (read-only or read-write depending on your needs):

```hcl
volumes = [
  {
    name      = "gcs-bucket"
    type      = "gcs"
    bucket    = module.storage.bucket_name
    read_only = false
  }
]

volume_mounts = [
  {
    name       = "gcs-bucket"
    mount_path = "/mnt/bucket"
  }
]
```

## IAM and Security

### Service Account
Assign a custom service account with minimal required permissions:

```hcl
module "service_account" {
  source = "./modules/service-account"
  
  account_id   = "cloud-run-sa"
  display_name = "Cloud Run Service Account"
  
  project_roles = [
    "roles/cloudsql.client",
    "roles/secretmanager.secretAccessor"
  ]
}

module "cloud_run" {
  # ... other configuration
  service_account = module.service_account.email
}
```

### Invoker Permissions
Control who can invoke your service:

```hcl
invokers = {
  "public" = ["allUsers"]                    # Public access
  "authenticated" = ["allAuthenticatedUsers"] # Authenticated users only
  "specific-service" = [
    "serviceAccount:caller@project.iam.gserviceaccount.com"
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
    "run.googleapis.com",
    "compute.googleapis.com"  # Required for VPC connectivity
  ]
}
```

### IAM Permissions

The service account or user running Terraform needs:

- `roles/run.admin` - To manage Cloud Run services
- `roles/iam.serviceAccountUser` - To assign service accounts
- `roles/compute.networkUser` - For VPC connectivity (if used)

## Best Practices

### Resource Optimization
1. **Right-size resources**: Start with smaller limits and scale up based on monitoring
2. **Use CPU idle**: Enable CPU throttling for cost optimization
3. **Configure min instances**: Set min instances > 0 for latency-sensitive applications

### Security
1. **Least privilege**: Use custom service accounts with minimal permissions
2. **Private traffic**: Use `INGRESS_TRAFFIC_INTERNAL_ONLY` for internal services
3. **Secrets management**: Store sensitive data in Secret Manager, not environment variables

### Performance
1. **Startup optimization**: Use `startup_cpu_boost` for faster cold starts
2. **VPC connectivity**: Use direct VPC interfaces for better performance than VPC connector
3. **Concurrency**: Configure appropriate concurrency based on your application

## Integration Examples

### With Database

```hcl
module "cloud_run" {
  source = "./modules/cloud-run"
  
  # ... basic configuration
  
  env = {
    DB_HOST = module.database.private_ip
    DB_NAME = module.database.database_name
    DB_USER = module.database.user_name
  }
  
  vpc_network_interface = {
    network    = module.networking.network_self_link
    subnetwork = module.networking.subnet_self_link
  }
}
```

### With Load Balancer

```hcl
module "cloud_run" {
  source = "./modules/cloud-run"
  
  # ... configuration
  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
}

# Configure load balancer to point to Cloud Run service
```

## Example Scenarios

This module is used in the following sample scenarios:

- **scenario-1-cloud-run-gcs**: Basic Cloud Run with Cloud Storage
- **scenario-3-vpc-connector**: Cloud Run with VPC connectivity
- **scenario-5-cloud-run-sql**: Cloud Run with Cloud SQL database
- **scenario-6-cloud-run-redis**: Cloud Run with Redis cache
- **scenario-7-cloud-run-vector-search**: Cloud Run with Vertex AI vector search
- **scenario-8-cloud-run-filestore**: Cloud Run with Filestore NFS
- **scenario-9-cloud-run-iap**: Cloud Run with Identity-Aware Proxy
- **scenario-10** through **scenario-12**: Various comprehensive Cloud Run deployments

## Monitoring and Troubleshooting

### Cloud Monitoring Metrics
- Request count and latency
- Instance count and utilization
- Memory and CPU usage
- Cold start frequency

### Common Issues
1. **Cold starts**: Increase min instances or optimize container startup
2. **Memory errors**: Increase memory limits or optimize application
3. **Timeout errors**: Increase timeout_seconds or optimize request handling
4. **Permission errors**: Verify service account permissions and IAM bindings

### Logging
Cloud Run automatically logs to Cloud Logging. Configure structured logging in your application for better observability.
