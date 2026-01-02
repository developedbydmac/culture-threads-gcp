# Service account for GKE nodes
resource "google_service_account" "gke_service_account" {
  account_id   = "${var.project_name}-gke-sa"
  display_name = "GKE Service Account"
  description  = "Service account for GKE cluster nodes"
}

# IAM binding for GKE service account
resource "google_project_iam_member" "gke_service_account_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/storage.objectViewer",
    "roles/artifactregistry.reader"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}

# Network module
module "network" {
  source = "./network"
  
  project_name = var.project_name
  project_id   = var.project_id
  region       = var.region
}

# GKE module
module "gke" {
  source = "./gke"
  
  project_name        = var.project_name
  project_id          = var.project_id
  region              = var.region
  vpc_network_id      = module.network.vpc_network_id
  gke_subnet_id       = module.network.gke_subnet_id
  gke_service_account = google_service_account.gke_service_account.email

  depends_on = [google_project_iam_member.gke_service_account_roles]
}
