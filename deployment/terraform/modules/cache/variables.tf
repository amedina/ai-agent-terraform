variable "project_id" {
  description = "The GCP project ID where the Memorystore Redis instance will be created"
  type        = string
}

variable "region" {
  description = "The GCP region where the Memorystore Redis instance will be deployed"
  type        = string
}

variable "name" {
  description = "The name of the Memorystore Redis instance"
  type        = string
}

variable "tier" {
  description = "The service tier for the Redis instance (BASIC for single node, STANDARD_HA for high availability)"
  type        = string
  default     = "STANDARD_HA"
}

variable "memory_size_gb" {
  description = "The memory size in GB for the Redis instance"
  type        = number
  default     = 1
}

variable "replica_count" {
  description = "The number of replica nodes (only applicable for STANDARD_HA tier)"
  type        = number
  default     = 1
}

variable "authorized_network" {
  description = "The VPC network authorized to access the Redis instance (full resource name)"
  type        = string
  default     = null
}
