resource "google_secret_manager_secret" "this" {
  for_each  = { for secret in var.secrets : secret.name => secret }
  secret_id = each.value.name
  project   = var.project_id
  labels    = merge(var.labels, each.value.labels)

  replication {
    dynamic "user_managed" {
      for_each = length(var.replication_locations) > 0 ? [1] : []
      content {
        dynamic "replicas" {
          for_each = var.replication_locations
          content {
            location = replicas.value
          }
        }
      }
    }

    dynamic "auto" {
      for_each = length(var.replication_locations) == 0 ? [1] : []
      content {}
    }
  }
}

resource "google_secret_manager_secret_version" "this" {
  for_each    = { for secret in var.secrets : secret.name => secret if secret.secret_data != null }
  secret      = google_secret_manager_secret.this[each.key].id
  secret_data = each.value.secret_data
}

resource "google_secret_manager_secret_iam_member" "members" {
  for_each  = {
    for binding in flatten([
      for secret in var.secrets : [
        for member in secret.iam_members : {
          key       = "${secret.name}-${member.role}-${member.member}"
          secret_id = secret.name
          role      = member.role
          member    = member.member
        }
      ]
    ]) : binding.key => binding
  }

  project   = var.project_id
  secret_id = google_secret_manager_secret.this[each.value.secret_id].secret_id
  role      = each.value.role
  member    = each.value.member
}
