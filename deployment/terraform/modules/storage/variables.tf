variable "project_id" {
  description = "The GCP project ID where the Cloud Storage bucket will be created"
  type        = string
}

variable "name" {
  description = "The name of the Cloud Storage bucket (must be globally unique)"
  type        = string
}

variable "location" {
  description = "The location for the Cloud Storage bucket (region or multi-region)"
  type        = string
}

variable "force_destroy" {
  description = "Whether to allow destruction of the bucket even if it contains objects"
  type        = bool
  default     = true
}

variable "public_access_prevention" {
  description = "Public access prevention setting for the bucket (enforced or inherited)"
  type        = string
  default     = "enforced"
}

variable "labels" {
  description = "A map of labels to assign to the Cloud Storage bucket"
  type        = map(string)
  default     = {}
}

variable "lifecycle_age_days" {
  description = "Number of days after which objects are deleted (0 disables lifecycle rule)"
  type        = number
  default     = 0
}
variable "iam_members" {
  description = "List of IAM bindings objects {role, member}"
  type = list(object({
    role   = string
    member = string
  }))
  default = []
}
