variable "project_id" {
  description = "The GCP project ID where the Cloud SQL instance will be created"
  type        = string
}

variable "region" {
  description = "The GCP region where the Cloud SQL instance will be deployed"
  type        = string
}

variable "instance_name" {
  description = "The name of the Cloud SQL instance (must be unique within the project)"
  type        = string
}

variable "database_version" {
  description = "The database engine version (e.g., POSTGRES_15, POSTGRES_14, MYSQL_8_0)"
  type        = string
  default     = "POSTGRES_15"
}

variable "tier" {
  description = "The machine tier for the Cloud SQL instance (e.g., db-f1-micro, db-n1-standard-1)"
  type        = string
  default     = "db-f1-micro"
}

variable "availability_type" {
  description = "The availability type for the Cloud SQL instance (ZONAL for single-zone, REGIONAL for high availability)"
  type        = string
  default     = "ZONAL"
}

variable "public_ip" {
  description = "Whether to assign a public IP address to the Cloud SQL instance"
  type        = bool
  default     = false
}

variable "authorized_networks" {
  description = "List of authorized networks for public IP access (only used if public_ip is true)"
  type        = list(object({ name = string, value = string }))
  default     = []
}

variable "private_network" {
  description = "The VPC network ID for private IP connectivity (required for private instances)"
  type        = string
  default     = null
}

variable "require_ssl" {
  description = "Whether to require SSL/TLS connections to the database instance"
  type        = bool
  default     = true
}

variable "backup_enabled" {
  description = "Whether to enable automated backups for the Cloud SQL instance"
  type        = bool
  default     = true
}

variable "database_name" {
  description = "The name of the initial database to create within the Cloud SQL instance"
  type        = string
}

variable "user_name" {
  description = "The username for the database user account"
  type        = string
}

variable "user_password" {
  description = "The password for the database user account (will be stored in Terraform state)"
  type        = string
  sensitive   = true
}
