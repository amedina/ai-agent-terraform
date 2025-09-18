output "host" {
  description = "The IP address of the Redis instance for client connections"
  value       = google_redis_instance.this.host
}

output "port" {
  description = "The port number of the Redis instance for client connections"
  value       = google_redis_instance.this.port
}
