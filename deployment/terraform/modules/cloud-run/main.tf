resource "google_cloud_run_v2_service" "this" {
  name     = var.name
  location = var.region
  project  = var.project_id

  template {
    service_account = var.service_account
    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }
    timeout = "${var.timeout_seconds}s"

    dynamic "volumes" {
      for_each = var.volumes
      content {
        name = volumes.value.name
        # Supports secret and gcs volumes
        dynamic "secret" {
          for_each = volumes.value.type == "secret" ? [1] : []
          content { secret = volumes.value.secret_name }
        }
        dynamic "gcs" {
          for_each = volumes.value.type == "gcs" ? [1] : []
          content {
            bucket    = volumes.value.bucket
            read_only = try(volumes.value.read_only, false)
          }
        }
      }
    }

    dynamic "vpc_access" {
      # Render vpc_access only if either vpc_connector or vpc_network_interface is provided
      for_each = var.vpc_connector == null && var.vpc_network_interface == null ? [] : [1]
      content {
        egress    = var.vpc_egress
        connector = var.vpc_connector
        dynamic "network_interfaces" {
          for_each = var.vpc_network_interface == null ? [] : [var.vpc_network_interface]
          content {
            network    = network_interfaces.value["network"]
            subnetwork = network_interfaces.value["subnetwork"]
          }
        }
      }
    }

    containers {
      image = var.image
      dynamic "env" {
        for_each = var.env
        content {
          name  = env.key
          value = env.value
        }
      }
      dynamic "volume_mounts" {
        for_each = var.volume_mounts
        content {
          name       = volume_mounts.value.name
          mount_path = volume_mounts.value.mount_path
        }
      }
      resources {
        limits = var.resource_limits
        cpu_idle = var.cpu_idle
        startup_cpu_boost = var.startup_cpu_boost
      }
    }
  }

  ingress = var.ingress
}

resource "google_cloud_run_v2_service_iam_binding" "invoker" {
  for_each = var.invokers
  name     = google_cloud_run_v2_service.this.name
  location = var.region
  role     = "roles/run.invoker"
  members  = each.value
}
