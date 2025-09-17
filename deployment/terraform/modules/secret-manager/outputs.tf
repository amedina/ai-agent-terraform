output "secret_ids" {
  description = "Map of secret names to their full resource IDs"
  value = {
    for name, secret in google_secret_manager_secret.this : name => secret.id
  }
}

output "secret_names" {
  description = "Map of secret names to their secret_id (short name)"
  value = {
    for name, secret in google_secret_manager_secret.this : name => secret.secret_id
  }
}

output "secret_versions" {
  description = "Map of secret names to their latest version names"
  value = {
    for name, version in google_secret_manager_secret_version.this : name => version.name
  }
}

output "all_secrets" {
  description = "Complete information about all created secrets"
  value = {
    for name, secret in google_secret_manager_secret.this : name => {
      id        = secret.id
      secret_id = secret.secret_id
      name      = secret.name
      labels    = secret.labels
    }
  }
}
