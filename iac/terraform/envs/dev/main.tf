terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.36"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Enable core APIs (optional but handy)
resource "google_project_service" "services" {
  for_each = toset([
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com"
  ])
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# --- NETWORK ---
module "network" {
  source      = "../../modules/network"
  project_id  = var.project_id
  region      = var.region
  vpc_name    = "finapp-vpc"
  subnet_name = "finapp-subnet"
  # subnet_cidr left as module default 10.20.0.0/20
}

# --- ARTIFACT REGISTRY ---
module "ar" {
  source     = "../../modules/artifact-registry"
  project_id = var.project_id
  location   = var.ar_location # e.g., "us"
  repo       = "finapp"        # repo name
}

# --- GKE CLUSTER ---
module "gke" {
  source       = "../../modules/gke"
  project_id   = var.project_id
  region       = var.region
  zone         = var.zone
  cluster_name = "finapp-gke"
  network      = module.network.network_self_link # <— matches module output
  subnet       = module.network.subnet_self_link  # <— matches module output
}

# --- CLOUD BUILD IAM ---
module "cb_iam" {
  source     = "../../modules/cloud-build-iam"
  project_id = var.project_id
}