data "google_storage_bucket_object_content" "internal_networks" {
  name   = "garvan_internal_networks.json"
  bucket = "gnomad-networking"
}
