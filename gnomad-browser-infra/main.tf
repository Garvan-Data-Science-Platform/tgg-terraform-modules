resource "google_service_account" "data_pipeline" {
  account_id   = "${var.infra_prefix}-data-pipeline"
  description  = "The service account for running the gnomAD data pipeline"
  display_name = "${var.infra_prefix} Data pipeline Service Account"
}

resource "google_project_iam_member" "data_pipeline_dataproc_worker" {
  role    = "roles/dataproc.worker"
  member  = google_service_account.data_pipeline.member
  project = var.project_id
}

# required for requesterPays resources
resource "google_project_iam_member" "data_pipeline_service_consumer" {
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = google_service_account.data_pipeline.member
  project = var.project_id
}

resource "google_storage_bucket_iam_member" "data_pipeline" {
  bucket = google_storage_bucket.data_pipeline.name
  role   = "roles/storage.admin"
  member = google_service_account.data_pipeline.member
}

resource "google_storage_bucket" "data_pipeline" {
  name                        = "${var.infra_prefix}-data-pipeline"
  location                    = var.data_pipeline_bucket_location
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = var.bucket_force_destroy

  labels = {
    "deployment" = var.infra_prefix
    "terraform"  = "true"
    "component"  = "data-pipeline"
  }
}
