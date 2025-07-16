# resource "google_redis_cluster" "redis_cluster" {
#   name    = var.name
#   region  = var.region
#   project = var.project_id

#   shard_count   = var.shard_count
#   replica_count = var.replica_count

#   transit_encryption_mode = "TRANSPORT_ENCRYPTION_MODE_SERVER_AUTHENTICATION"
#   authorization_mode      = var.authorization_mode

#   psc_configs {
#     network = var.authorized_network
#   }
# }
