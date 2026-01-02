output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.main.name
}

output "vpc_network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.main.id
}

output "gke_subnet_name" {
  description = "Name of the GKE subnet"
  value       = google_compute_subnetwork.gke.name
}

output "gke_subnet_id" {
  description = "ID of the GKE subnet"
  value       = google_compute_subnetwork.gke.id
}

output "pods_ip_cidr_range" {
  description = "IP CIDR range for pods"
  value       = google_compute_subnetwork.gke.secondary_ip_range[0].ip_cidr_range
}

output "services_ip_cidr_range" {
  description = "IP CIDR range for services"
  value       = google_compute_subnetwork.gke.secondary_ip_range[1].ip_cidr_range
}