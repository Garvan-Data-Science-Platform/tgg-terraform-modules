provider "google" {
  project = var.project_name 
  region = var.region
}

# Default compute service account
resource "google_project_iam_member" "default_compute_admin" {
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_project.current_project.number}-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "default_compute_dataproc_worker" {
  role    = "roles/dataproc.worker"
  member  = "serviceAccount:${google_project.current_project.number}-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "default_compute_object_admin" {
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_project.current_project.number}-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "default_compute_service_usage" {
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${google_project.current_project.number}-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "default_compute_artifact_read" {
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_project.current_project.number}-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_custom_role" "bucket_list_role" {
  role_id     = "gnomADProjBucketList"
  title       = "gnomAD Project Bucket List"
  description = "Provides access to list GCS buckets"
  permissions = ["storage.buckets.list"]
}

resource "google_project_iam_member" "default_compute_bucket_list" {
  role    = google_project_iam_custom_role.bucket_list_role.id
  member  = "serviceAccount:${google_project.current_project.number}-compute@developer.gserviceaccount.com"
}

# Project Owner group
resource "google_project_iam_member" "owner_group" {
  role    = "roles/owner"
  member  = "group:${var.owner_group_id}"
}

# Permissions for primary user of the GCP project
resource "google_project_iam_member" "primary_user_editor" {
  role    = "roles/editor"
  member  = var.primary_user_principal
}

resource "google_project_iam_member" "primary_iap_tunnel_access" {
  role    = "roles/iap.tunnelResourceAccessor"
  member  = var.primary_user_principal
}

resource "google_project_iam_member" "primary_user_artifact_reg_admin" {
  role    = "roles/artifactregistry.admin"
  member  = var.primary_user_principal
}

# If one is provided, grant storage read/write and artifact registry read access to a hail batch service account
resource "google_project_iam_member" "hail_batch_object_admin" {
  count   = length(var.hail_batch_service_account) > 0 ? 1 : 0
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${var.hail_batch_service_account}"
}

resource "google_project_iam_member" "hail_batch_bucket_list" {
  count   = length(var.hail_batch_service_account) > 0 ? 1 : 0
  role    = google_project_iam_custom_role.bucket_list_role.id
  member  = "serviceAccount:${var.hail_batch_service_account}"
}

resource "google_project_iam_member" "hail_batch_artifact_read" {
  count   = length(var.hail_batch_service_account) > 0 ? 1 : 0
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${var.hail_batch_service_account}"
}

# Grant serviceusage.use permissions to Batch SA (allow SA to use project)
resource "google_project_iam_member" "hail_batch_service_usage" {
  count   = length(var.hail_batch_service_account) > 0 ? 1 : 0
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${var.hail_batch_service_account}"
}

resource "google_project_iam_member" "billing_manager_access" {
  count   = var.enable_cost_control ? 1 : 0
  role    = "roles/billing.projectManager"
  member  = "serviceAccount:${var.cost_control_service_account}"
}

resource "google_project_iam_member" "billing_browser_access" {
  count   = var.enable_cost_control ? 1 : 0
  role    = "roles/browser"
  member  = "serviceAccount:${var.cost_control_service_account}"
}
