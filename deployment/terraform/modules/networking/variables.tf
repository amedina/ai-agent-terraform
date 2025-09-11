variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
}

variable "subnets" {
  description = "List of subnet objects { name, cidr, region, private_ip_google_access? }"
  type = list(object({
    name                      = string
    cidr                      = string
    region                    = string
    private_ip_google_access  = optional(bool)
  }))
  default = []
}

variable "enable_nat" {
  type        = bool
  default     = true
  description = "Create Cloud NAT for outbound access"
}

variable "router_name" {
  description = "Name of the Cloud Router for NAT gateway"
  type        = string
  default     = "nat-router"
}

variable "router_region" {
  type        = string
  description = "Region for router/NAT"
}

variable "nat_name" {
  description = "Name of the Cloud NAT gateway"
  type        = string
  default     = "nat-gateway"
}

variable "nat_log_enable" {
  description = "Whether to enable logging for the Cloud NAT gateway"
  type        = bool
  default     = true
}

variable "nat_log_filter" {
  description = "Log filter for Cloud NAT (ERRORS_ONLY, TRANSLATIONS_ONLY, ALL)"
  type        = string
  default     = "ERRORS_ONLY"
}

variable "enable_private_service_connect" {
  type        = bool
  default     = false
  description = "Enable Private Service Connect (Service Networking)"
}

variable "private_service_range_name" {
  description = "Name of the private IP range for service networking"
  type        = string
  default     = "private-service-range"
}

variable "private_service_range_prefix" {
  description = "Prefix length for the private service IP range (e.g., 24 for /24 subnet)"
  type        = number
  default     = 24
}
