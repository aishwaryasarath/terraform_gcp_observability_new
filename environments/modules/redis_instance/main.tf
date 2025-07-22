resource "google_redis_instance" "redis_instance" {
  name               = var.name
  region             = var.region
  tier               = var.tier
  memory_size_gb     = var.memory_size_gb
  read_replicas_mode = var.read_replicas_mode
  display_name       = var.display_name
  project            = var.project
  replica_count      = var.replica_count
}
