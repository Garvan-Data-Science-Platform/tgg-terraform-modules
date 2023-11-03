terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.3.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_storage_bucket" "default" {
  name  = "gnomad-tf-remote-state"
  force_destroy = false
  location = var.region
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "networking" {
  name  = "gnomad-networking"
  location = var.region
  storage_class = "STANDARD"
}
