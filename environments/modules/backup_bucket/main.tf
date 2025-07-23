resource "google_storage_bucket" "backup_bucket" {
  name          = var.name
  location      = var.location
  project       = var.project
  storage_class = var.storage_class
  force_destroy = var.force_destroy
  versioning {
    enabled = var.versioning
  }
  uniform_bucket_level_access = true

}
