terraform {
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.36" }
  }
}

variable "project_id" {}
variable "location" { default = "us" } # e.g., "us" or "us-central1"
variable "repo" { default = "finapp" }

provider "google" { project = var.project_id }

resource "google_artifact_registry_repository" "docker" {
  location      = var.location
  repository_id = var.repo
  description   = "FinApp Docker images"
  format        = "DOCKER"
}

# Example: us-docker.pkg.dev/PROJECT/finapp
output "repo_path" {
  value = "${var.location}-docker.pkg.dev/${var.project_id}/${var.repo}"
}
