terraform {
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.36" }
  }
}

#############################################
# Inputs / Provider
#############################################
variable "project_id" {
  type = string
}

provider "google" {
  project = var.project_id
}

data "google_project" "proj" {}

#############################################
# 1) Service account used by Cloud Build jobs
#############################################
resource "google_service_account" "cb_deployer" {
  account_id   = "cloudbuild-deployer"
  display_name = "Cloud Build Deployer"
}

#############################################
# 2) Allow Cloud Build to act as this SA
#    (so you can pass --service-account=<this SA> on gcloud builds submit)
#
# Principals used by Cloud Build:
#  - Cloud Build Service Account: <PROJECT_NUMBER>@cloudbuild.gserviceaccount.com
#  - Cloud Build Service Agent:   service-<PROJECT_NUMBER>@gcp-sa-cloudbuild.iam.gserviceaccount.com
#
# Grants:
#  - iam.serviceAccountUser         → needed to "use" the SA
#  - iam.serviceAccountTokenCreator → needed by service agent to mint tokens
#############################################
resource "google_service_account_iam_member" "allow_cb_sa_user" {
  service_account_id = google_service_account.cb_deployer.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${data.google_project.proj.number}@cloudbuild.gserviceaccount.com"
}

resource "google_service_account_iam_member" "allow_cb_agent_user" {
  service_account_id = google_service_account.cb_deployer.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:service-${data.google_project.proj.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}

resource "google_service_account_iam_member" "allow_cb_agent_token_creator" {
  service_account_id = google_service_account.cb_deployer.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-${data.google_project.proj.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}

#############################################
# 3) Project-level roles for the deployer SA
#    (enough for smoke test: push images and deploy to GKE)
#############################################
resource "google_project_iam_member" "ar_writer" {
  project = data.google_project.proj.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cb_deployer.email}"
}

resource "google_project_iam_member" "gke_developer" {
  project = data.google_project.proj.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.cb_deployer.email}"
}

# Optional but convenient for first deploys; remove later for stricter least-priv
resource "google_project_iam_member" "gke_admin" {
  project = data.google_project.proj.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.cb_deployer.email}"
}

#############################
