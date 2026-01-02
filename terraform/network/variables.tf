variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "culture-threads"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-east1"
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}