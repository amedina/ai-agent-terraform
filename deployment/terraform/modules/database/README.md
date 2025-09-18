# Database Module

This Terraform module provisions Google Cloud SQL instances for managed relational databases with high availability,
security, and automated backups. It supports PostgreSQL and MySQL databases with configurable networking options.

## Features

- **Managed Database**: Fully managed PostgreSQL/MySQL with automatic updates and maintenance
- **High Availability**: Support for regional availability with automatic failover
- **Private Networking**: VPC-native deployment with private IP addresses
- **Security**: SSL encryption and authorized network controls
- **Automated Backups**: Configurable backup schedules and retention
- **User Management**: Database user creation with secure password handling

## Resources Created

- `google_sql_database_instance` - Cloud SQL database instance
- `google_sql_database` - Database within the instance
- `google_sql_user` - Database user with specified credentials

## Usage

### Basic PostgreSQL Database

```hcl
module "database" {
  source = "./modules/database"

  project_id    = "my-gcp-project"
  region        = "us-central1"
  instance_name = "my-postgres-db"
  database_name = "application_db"
  user_name     = "app_user"
  user_password = var.db_password

  database_version = "POSTGRES_15"
  tier             = "db-custom-2-4096"  # 2 vCPUs, 4GB RAM
}
```

### High Availability Database with Private Network

```hcl
module "database" {
  source = "./modules/database"

  project_id    = var.project_id
  region        = var.region
  instance_name = "prod-postgres"
  database_name = "production_db"
  user_name     = "prod_user"
  user_password = var.db_password

  database_version  = "POSTGRES_15"
  tier              = "db-custom-4-8192"
  availability_type = "REGIONAL"

  public_ip       = false
  private_network = module.networking.network_self_link
  require_ssl     = true
  backup_enabled  = true
}
```

### MySQL Database with Public Access

```hcl
module "database" {
  source = "./modules/database"

  project_id    = var.project_id
  region        = var.region
  instance_name = "mysql-instance"
  database_name = "app_db"
  user_name     = "mysql_user"
  user_password = var.mysql_password

  database_version = "MYSQL_8_0"
  tier             = "db-n1-standard-1"

  public_ip = true
  authorized_networks = [
    {
      name  = "office-network"
      value = "203.0.113.0/24"
    },
    {
      name  = "home-office"
      value = "198.51.100.1/32"
    }
  ]
}
```

## Variables

### Required Variables

| Name            | Type     | Description                          |
|-----------------|----------|--------------------------------------|
| `project_id`    | `string` | GCP Project ID                       |
| `region`        | `string` | GCP region for the database instance |
| `instance_name` | `string` | Name of the Cloud SQL instance       |
| `database_name` | `string` | Name of the database to create       |
| `user_name`     | `string` | Database user name                   |
| `user_password` | `string` | Database user password               |

### Optional Variables

| Name                  | Type           | Default         | Description                              |
|-----------------------|----------------|-----------------|------------------------------------------|
| `database_version`    | `string`       | `"POSTGRES_15"` | Database engine and version              |
| `tier`                | `string`       | `"db-f1-micro"` | Machine type for the instance            |
| `availability_type`   | `string`       | `"ZONAL"`       | Availability type (ZONAL or REGIONAL)    |
| `public_ip`           | `bool`         | `false`         | Whether to enable public IP              |
| `private_network`     | `string`       | `null`          | VPC network for private IP               |
| `require_ssl`         | `bool`         | `true`          | Whether to require SSL connections       |
| `backup_enabled`      | `bool`         | `true`          | Whether to enable automated backups      |
| `authorized_networks` | `list(object)` | `[]`            | Authorized networks for public IP access |

## Outputs

| Name                       | Description                               |
|----------------------------|-------------------------------------------|
| `instance_connection_name` | Connection name for the database instance |
| `instance_self_link`       | Self link of the database instance        |
| `database_name`            | Name of the created database              |
| `user_name`                | Name of the created database user         |

## Database Versions

### PostgreSQL

- `POSTGRES_15` (recommended)
- `POSTGRES_14`
- `POSTGRES_13`

### MySQL

- `MYSQL_8_0` (recommended)
- `MYSQL_5_7`

## Machine Types

### Shared-core instances (burstable)

- `db-f1-micro` - 1 shared vCPU, 0.6GB RAM
- `db-g1-small` - 1 shared vCPU, 1.7GB RAM

### Custom instances

- `db-custom-{cpus}-{memory_mb}` - Custom vCPUs and memory
- Example: `db-custom-4-8192` (4 vCPUs, 8GB RAM)

### Standard instances

- `db-n1-standard-1` - 1 vCPU, 3.75GB RAM
- `db-n1-standard-2` - 2 vCPUs, 7.5GB RAM
- `db-n1-highmem-2` - 2 vCPUs, 13GB RAM

## Prerequisites

### APIs Required

```hcl
module "apis" {
  source = "./modules/apis"

  project_id = var.project_id
  services = [
    "sqladmin.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com"  # For private networking
  ]
}
```

### Private Network Setup

For private databases, ensure VPC and service networking are configured:

```hcl
module "networking" {
  source = "./modules/networking"
  # ... configuration
}

# Private service connection is handled by the networking module
```

## Connection Examples

### From Cloud Run

```hcl
module "cloud_run" {
  source = "./modules/cloud-run"

  # ... other configuration

  env = {
    DB_HOST = "/cloudsql/${module.database.instance_connection_name}"
    DB_NAME = module.database.database_name
    DB_USER = module.database.user_name
    DB_PASS = var.db_password
  }

  # For private IP connections
  vpc_network_interface = {
    network    = module.networking.network_self_link
    subnetwork = module.networking.subnet_self_link
  }
}
```

### Connection Strings

#### PostgreSQL

```
postgresql://username:password@host:5432/database
```

#### MySQL

```
mysql://username:password@host:3306/database
```

### Using Cloud SQL Proxy

For secure connections without VPC:

```bash
# Download and run Cloud SQL Proxy
cloud_sql_proxy -instances=PROJECT_ID:REGION:INSTANCE_NAME=tcp:5432
```

## Security Best Practices

1. **Use Private IPs**: Set `public_ip = false` for production
2. **Enable SSL**: Always use `require_ssl = true`
3. **Strong Passwords**: Use random, complex passwords
4. **Network Security**: Restrict `authorized_networks` for public instances
5. **IAM Authentication**: Consider using IAM database authentication
6. **Backup Encryption**: Backups are encrypted by default

## Monitoring and Maintenance

### Cloud Monitoring Metrics

- CPU utilization
- Memory utilization
- Database connections
- Disk usage
- Query performance

### Automated Backups

- Daily automatic backups (configurable)
- Point-in-time recovery
- Cross-region backup replication (optional)

## Example Scenarios

This module is used in the following sample scenarios:

- **scenario-5-cloud-run-sql**: Cloud Run application with Cloud SQL database

## Limitations

- Instance names must be globally unique within GCP
- Instance cannot be deleted for 7 days after deletion (backup retention)
- Some machine types may not be available in all regions
- Database flags cannot be modified for some settings after creation

## Troubleshooting

### Common Issues

1. **Connection timeouts**: Ensure proper VPC configuration for private instances
2. **SSL errors**: Verify SSL certificates and `require_ssl` setting
3. **Permission denied**: Check IAM permissions and authorized networks
4. **Instance name conflicts**: Use unique instance names across your organization

### Performance Tuning

1. **Right-size instances**: Monitor usage and adjust machine type
2. **Connection pooling**: Use connection pooling in applications
3. **Query optimization**: Analyze slow queries and add appropriate indexes
4. **Read replicas**: Consider read replicas for read-heavy workloads
