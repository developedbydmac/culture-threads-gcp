variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "culture-threads"
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-east1"
}

variable "vpc_network_id" {
  description = "VPC network ID"
  type        = string
}

variable "gke_subnet_id" {
  description = "GKE subnet ID"
  type        = string
}

variable "gke_service_account" {
  description = "Service account for GKE nodes"
  type        = string
}