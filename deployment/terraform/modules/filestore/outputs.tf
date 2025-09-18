output "ip_addresses" { value = google_filestore_instance.this.networks[0].ip_addresses }
output "mount_ip" { value = google_filestore_instance.this.networks[0].ip_addresses[0] }
output "share_name" { value = google_filestore_instance.this.file_shares[0].name }
