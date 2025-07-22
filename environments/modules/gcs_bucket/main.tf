resource "google_storage_bucket" "default" {
  name     = var.name
  location = var.location
  # force_destroy = true
  # project       = var.project
  # storage_class = var.storage_class
  # versioning    = var.versioning
}
