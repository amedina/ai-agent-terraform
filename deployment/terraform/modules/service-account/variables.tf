variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "account_id" {
  description = "Service account ID (without domain)"
  type        = string
}

variable "display_name" {
  description = "Display name"
  type        = string
  default     = null
}

variable "project_roles" {
  description = "Set of project roles to bind to the service account"
  type        = set(string)
  default     = []
}
