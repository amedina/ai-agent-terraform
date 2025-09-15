output "bucket_name" {
  description = "The name of the created Cloud Storage bucket"
  value       = google_storage_bucket.this.name
}

output "bucket_url" {
  description = "The base URL of the created Cloud Storage bucket (gs://bucket-name)"
  value       = google_storage_bucket.this.url
}
