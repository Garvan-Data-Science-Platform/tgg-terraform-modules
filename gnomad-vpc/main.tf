module "gnomad-vpc" {
  source       = "github.com/Garvan-Data-Science-Platform/tgg-terraform-modules//vpc-with-nat-subnet?ref=2-generalise-modules"
  network_name = var.network_name_prefix
  subnets = [
    {
      subnet_name_suffix           = "gke"
      subnet_region                = var.subnet_region
      ip_cidr_range                = var.gke_primary_subnet_range
      enable_private_google_access = true
      subnet_flow_logs             = false
      subnet_flow_logs_sampling    = "0.5"
      subnet_flow_logs_metadata    = "EXCLUDE_ALL_METADATA"
      subnet_flow_logs_filter      = "true"
    },
    {
      subnet_name_suffix           = "dataproc"
      subnet_region                = var.subnet_region
      ip_cidr_range                = var.dataproc_primary_subnet_range
      enable_private_google_access = true
      subnet_flow_logs             = false
      subnet_flow_logs_sampling    = "0.5"
      subnet_flow_logs_metadata    = "EXCLUDE_ALL_METADATA"
      subnet_flow_logs_filter      = "true"
    }
  ]
}

# Firewalls

resource "google_compute_firewall" "dataproc_internal" {
  name        = "${var.network_name_prefix}-dataproc-internal-allow"
  network     = module.gnomad-vpc.vpc_network_name
  description = "Creates firewall rule allowing dataproc tagged instances to reach all other hosts on the network"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_tags = ["dataproc-node"]
}

# allows SSH access from the Identity Aware Proxy service (for cloud-console based SSH sessions)
resource "google_compute_firewall" "iap_forwarding" {
  name    = "${var.network_name_prefix}-iap-access"
  network = module.gnomad-vpc.vpc_network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

# allows SSH access from an authorized network
resource "google_compute_firewall" "ssh-from-home" {
  name    = "${var.network_name_prefix}-ssh-from-home"
  network = module.gnomad-vpc.vpc_network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.authorized_networks
}
