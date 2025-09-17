variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "labels" {
  description = "Labels to apply to all secrets"
  type        = map(string)
  default     = {}
}

variable "replication_locations" {
  description = "List of locations for user-managed replication. If empty, uses automatic replication"
  type        = list(string)
  default     = []
}

variable "secrets" {
  description = "List of secrets to create"
  type = list(object({
    name        = string
    secret_data = optional(string)
    labels      = optional(map(string), {})
    iam_members = optional(list(object({
      role   = string
      member = string
    })), [])
  }))
  default = []
}
