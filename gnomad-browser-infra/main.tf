resource "google_service_account" "gke_cluster_sa" {
  account_id   = "${var.infra_prefix}-gke-nodes"
  description  = "The service account to run the GKE nodes with"
  display_name = "${var.infra_prefix} GKE nodes"
}

resource "google_project_iam_member" "gke_nodes_iam" {
  for_each = toset([
    "logging.logWriter",
    "monitoring.metricWriter",
    "monitoring.viewer",
    "stackdriver.resourceMetadata.writer",
    "storage.objectViewer"
  ])

  role    = "roles/${each.key}"
  member  = "serviceAccount:${google_service_account.gke_cluster_sa.email}"
  project = var.project_id
}

# A document containing the Broad's public IP subnets for allowing Office and VPN IPs in firewalls
data "google_storage_bucket_object_content" "internal_networks" {
  name   = "internal_networks.json"
  bucket = "broad-institute-networking"
}

resource "google_container_cluster" "browser_cluster" {
  name            = "${var.infra_prefix}-cluster"
  location        = var.gke_control_plane_zone
  network         = var.vpc_network_name
  subnetwork      = var.vpc_subnet_name
  networking_mode = "VPC_NATIVE"

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = toset(jsondecode(data.google_storage_bucket_object_content.internal_networks.content))
      content {
        cidr_block = cidr_blocks.key
      }
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.gke_cluster_secondary_range_name
    services_secondary_range_name = var.gke_services_secondary_range_name
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  private_cluster_config {
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.gke_control_plane_cidr_range
    enable_private_endpoint = false
  }

  release_channel {
    channel = "STABLE"
  }
}

resource "google_container_node_pool" "main_pool" {
  name       = "main-pool"
  location   = var.gke_main_pool_zone != "" ? var.gke_main_pool_zone : var.gke_control_plane_zone
  cluster    = google_container_cluster.browser_cluster.name
  node_count = var.gke_main_pool_num_nodes

  node_config {
    preemptible  = true
    machine_type = var.gke_main_pool_machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke_cluster_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}

resource "google_container_node_pool" "redis_pool" {
  name       = "redis"
  location   = var.gke_redis_pool_zone != "" ? var.gke_redis_pool_zone : var.gke_control_plane_zone
  cluster    = google_container_cluster.browser_cluster.name
  node_count = var.gke_redis_pool_num_nodes

  node_config {
    machine_type = var.gke_redis_pool_machine_type

    service_account = google_service_account.gke_cluster_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}

resource "google_container_node_pool" "es_data_pool" {
  name       = "es-data"
  location   = var.gke_es_data_pool_zone != "" ? var.gke_es_data_pool_zone : var.gke_control_plane_zone
  cluster    = google_container_cluster.browser_cluster.name
  node_count = var.gke_es_data_pool_num_nodes

  node_config {
    machine_type    = var.gke_es_data_pool_machine_type
    service_account = google_service_account.gke_cluster_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}
