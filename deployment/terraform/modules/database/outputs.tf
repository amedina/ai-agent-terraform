output "instance_connection_name" {
  description = "The connection name of the Cloud SQL instance for connecting from applications (format: project:region:instance-name)"
  value       = google_sql_database_instance.this.connection_name
}

output "instance_self_link" {
  description = "The URI of the created Cloud SQL instance"
  value       = google_sql_database_instance.this.self_link
}

output "database_name" {
  description = "The name of the created database within the Cloud SQL instance"
  value       = google_sql_database.db.name
}

output "user_name" {
  description = "The username of the created database user account"
  value       = google_sql_user.user.name
}
