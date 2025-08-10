output "gke_cluster_name" {
  value = module.gke.cluster_name
}

output "gke_cluster_zone" {
  value = var.zone
}

output "artifact_registry_repo_path" {
  # Example: us-docker.pkg.dev/PROJECT/finapp
  value = module.ar.repo_path
}

output "how_to_get_credentials" {
  value = "gcloud container clusters get-credentials ${module.gke.cluster_name} --zone ${var.zone} --project ${var.project_id}"
}
