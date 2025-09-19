resource "google_storage_bucket" "this" {
  name                        = var.name
  project                     = var.project_id
  location                    = var.location
  force_destroy               = var.force_destroy
  uniform_bucket_level_access = true
  public_access_prevention    = var.public_access_prevention
  labels                      = var.labels
  lifecycle_rule {
    condition {
      age = var.lifecycle_age_days
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket_iam_member" "members" {
  # Use static index-based keys to avoid unknown values in for_each keys during plan
  for_each = { for idx, m in var.iam_members : tostring(idx) => m }
  bucket   = google_storage_bucket.this.name
  role     = each.value.role
  member   = each.value.member
}
