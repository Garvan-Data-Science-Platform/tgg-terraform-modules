variable "network_name_prefix" {
  description = "The string that should be used to prefix nets, subnets, nats, etc created by this module"
  type        = string
}

variable "gke_primary_subnet_range" {
  description = "The IP address range to use for the primary gke subnet"
  type        = string
  default     = "192.168.0.0/20"
}

variable "dataproc_primary_subnet_range" {
  description = "The IP address range to use for the primary dataproc subnet"
  type        = string
  default     = "192.168.255.0/24"
}

variable "vpc_sub_module_source" {
  type        = string
  description = "The URL of repository and specific release of vpc-with-nat-subnet module"
  default     = "github.com/broadinstitute/tgg-terraform-modules//vpc-with-nat-subnet?ref=vpc-with-nat-subnet-v1.0.0"
}

variable "subnet_region" {
  type        = string
  description = "For managed items that require a region/location"
  default     = "us-central1"
}

variable "project_id" {
  type        = string
  description = "The unique id of the project."
}

variable "default_resource_region" {
  type        = string
  description = "For managed items that require a region/location"
  default     = "us-central1"
}
