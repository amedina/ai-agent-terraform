resource "google_sql_database_instance" "this" {
  name             = var.instance_name
  project          = var.project_id
  region           = var.region
  database_version = var.database_version

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    ip_configuration {
      ipv4_enabled    = var.public_ip
      private_network = var.private_network
      require_ssl     = var.require_ssl
      authorized_networks = var.public_ip ? var.authorized_networks : []
    }
    backup_configuration {
      enabled = var.backup_enabled
    }
  }
}

resource "google_sql_database" "db" {
  name     = var.database_name
  instance = google_sql_database_instance.this.name
}

resource "google_sql_user" "user" {
  name     = var.user_name
  instance = google_sql_database_instance.this.name
  password = var.user_password
}
