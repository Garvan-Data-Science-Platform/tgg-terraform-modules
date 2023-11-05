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

variable "subnet_region" {
  type        = string
  description = "For managed items that require a region/location"
  default     = "australia-southeast1"
}

variable "project_id" {
  type        = string
  description = "The unique id of the project."
}

variable "default_resource_region" {
  type        = string
  description = "For managed items that require a region/location"
  default     = "australia-southeast1"
}
