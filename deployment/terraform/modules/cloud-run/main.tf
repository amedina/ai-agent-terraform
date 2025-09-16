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
        # Support GCS or Filestore via CSI drivers - for now just emptyDir / secret
        dynamic "empty_dir" {
          for_each = volumes.value.type == "emptyDir" ? [1] : []
          content {}
        }
        dynamic "secret" {
          for_each = volumes.value.type == "secret" ? [1] : []
          content { secret = volumes.value.secret_name }
        }
      }
    }

    vpc_access {
      egress = var.vpc_egress
      dynamic "network_interfaces" {
        for_each = var.vpc_network_interface == null ? [] : [var.vpc_network_interface]
        content {
          network    = network_interfaces.value.network
          subnetwork = network_interfaces.value.subnetwork
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
