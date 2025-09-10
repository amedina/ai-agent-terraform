variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "services" {
  description = "List of APIs to enable"
  type        = list(string)
  default     = []
}

variable "disable_on_destroy" {
  description = "Whether to disable APIs on destroy"
  type        = bool
  default     = false
}
