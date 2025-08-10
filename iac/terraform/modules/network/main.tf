terraform {
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.36" }
  }
}

variable "project_id" {}
variable "region" { default = "us-central1" }
variable "vpc_name" { default = "finapp-vpc" }
variable "subnet_name" { default = "finapp-subnet" }
variable "subnet_cidr" { default = "10.20.0.0/20" }

provider "google" { project = var.project_id }

resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name                     = var.subnet_name
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name    = "${var.vpc_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.vpc_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Outputs (self_links are what GKE expects)
output "network_self_link" { value = google_compute_network.vpc.self_link }
output "subnet_self_link" { value = google_compute_subnetwork.subnet.self_link }
