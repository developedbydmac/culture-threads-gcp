# GKE Cluster
resource "google_container_cluster" "main" {
  name     = "${var.project_name}-gke-cluster"
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.vpc_network_id
  subnetwork = var.gke_subnet_id

  # IP allocation policy for VPC-native cluster
  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }

  # Master authorized networks
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All"
    }
  }

  # Enable network policy
  network_policy {
    enabled = true
  }

  # Enable workload identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Disable logging and monitoring for cost optimization (can be enabled later)
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
}

# Node Pool
resource "google_container_node_pool" "main" {
  name       = "${var.project_name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.main.name
  node_count = 2

  node_config {
    preemptible  = true  # Use preemptible instances for cost savings
    machine_type = "e2-small"  # Smaller machine type
    disk_size_gb = 30         # Smaller disk to fit quota

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = var.gke_service_account
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = "dev"
      project     = var.project_name
    }

    tags = ["gke-node", "${var.project_name}-gke"]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}