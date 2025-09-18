resource "google_iap_brand" "brand" {
  count        = var.create_brand ? 1 : 0
  project      = var.project_id
  application_title = var.application_title
  support_email     = var.support_email
}

resource "google_iap_client" "client" {
  count       = var.create_client ? 1 : 0
  brand       = var.create_brand ? google_iap_brand.brand[0].name : var.brand_name
  display_name = var.client_display_name
}

resource "google_iap_web_iam_binding" "binding" {
  project = var.project_id
  role    = "roles/iap.httpsResourceAccessor"
  members = var.members
}
