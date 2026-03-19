terraform {
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.36" }
  }
}

variable "project_id" {}
variable "region" { default = "us-central1" }
variable "zone" { default = "us-central1-a" }
variable "cluster_name" { default = "finapp-gke" }
variable "network" {}
variable "subnet" {}

provider "google" { project = var.project_id }

resource "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.zone

  network    = var.network
  subnetwork = var.subnet

  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {}
  networking_mode = "VPC_NATIVE"

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    managed_prometheus {
      enabled = true
    }
  }
  
 deletion_protection = false  
}

resource "google_container_node_pool" "default" {
  name       = "default-pool"
  location   = var.zone
  cluster    = google_container_cluster.gke.name
  node_count = 2

  node_config {
    machine_type = "e2-standard-2"
    image_type   = "COS_CONTAINERD"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    labels       = { purpose = "finapp" }
    metadata     = { disable-legacy-endpoints = "true" }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

output "cluster_name" { value = google_container_cluster.gke.name }
output "cluster_zone" { value = var.zone }
