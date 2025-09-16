variable "project_id" {
  description = "The GCP project ID where the Cloud Run service will be deployed"
  type        = string
}

variable "region" {
  description = "The GCP region where the Cloud Run service will be deployed"
  type        = string
}

variable "name" {
  description = "The name of the Cloud Run service"
  type        = string
}

variable "image" {
  description = "The container image URL to deploy (e.g., gcr.io/project/image:tag)"
  type        = string
}

variable "service_account" {
  description = "The service account email to use for the Cloud Run service (uses default if null)"
  type        = string
  default     = null
}

variable "min_instances" {
  description = "The minimum number of container instances to keep warm (0 for scale-to-zero)"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "The maximum number of container instances to scale up to"
  type        = number
  default     = 3
}

variable "timeout_seconds" {
  description = "The maximum time in seconds for a request to complete before timing out"
  type        = number
  default     = 300
}

variable "ingress" {
  description = "The ingress traffic settings (INGRESS_TRAFFIC_ALL, INGRESS_TRAFFIC_INTERNAL_ONLY, INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER)"
  type        = string
  default     = "INGRESS_TRAFFIC_ALL"
}

variable "vpc_egress" {
  description = "The VPC egress settings (ALL_TRAFFIC, PRIVATE_RANGES_ONLY)"
  type        = string
  default     = "PRIVATE_RANGES_ONLY"
}
variable "vpc_network_interface" {
  description = "Object {network, subnetwork} for direct VPC access"
  type = object({
    network    = string
    subnetwork = string
  })
  default = null
}
variable "env" {
  description = "Environment variables as key-value pairs (deprecated: use env_vars for secret support)"
  type        = map(string)
  default     = {}
}

variable "env_vars" {
  description = "List of environment variables with support for secrets"
  type = list(object({
    name = string
    value = optional(string)
    value_source = optional(object({
      secret_key_ref = object({
        secret  = string
        version = string
      })
    }))
  }))
  default = []
}

variable "volumes" {
  description = "List of volumes to mount in the container (supports emptyDir and secret types)"
  type = list(object({
    name        = string
    type        = string # emptyDir|secret
    secret_name = optional(string)
  }))
  default = []
}

variable "volume_mounts" {
  description = "List of volume mounts specifying volume name and mount path in the container"
  type        = list(object({ name = string, mount_path = string }))
  default     = []
}

variable "resource_limits" {
  description = "Resource limits for the container (cpu and memory)"
  type        = map(string)
  default     = { cpu = "1", memory = "512Mi" }
}

variable "cpu_idle" {
  description = "Whether CPU is allocated only during request processing (true for cost optimization)"
  type        = bool
  default     = true
}

variable "startup_cpu_boost" {
  description = "Whether to boost CPU allocation during container startup for faster cold starts"
  type        = bool
  default     = true
}
variable "invokers" {
  description = "Map of binding name to list of members for roles/run.invoker"
  type        = map(list(string))
  default     = {}
}
