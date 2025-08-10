variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "ar_location" {
  description = "Artifact Registry location (e.g., 'us' or a specific region)"
  type        = string
  default     = "us"
}
