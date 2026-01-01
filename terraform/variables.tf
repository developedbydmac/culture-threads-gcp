variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-east1"
}

variable "zone" {
  description = "GCP zone for resources"
  type        = string
  default     = "us-east1-b"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "culture-threads-cluster"
}

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = "culture-threads-vpc"
}

variable "db_instance_name" {
  description = "Cloud SQL instance name"
  type        = string
  default     = "culture-threads-db"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "culturethreads"
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "app_user"
}