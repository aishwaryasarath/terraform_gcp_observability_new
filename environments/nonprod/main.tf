locals {
  regions = {
    us-central1 = var.regions["us-central1"].region
    us-east1    = var.regions["us-east1"].region
  }
  region_aliases = {
    us-central1 = var.regions["us-central1"].region_alias
    us-east1    = var.regions["us-east1"].region_alias
  }
}



# module "redis_instance" {
#   for_each           = local.regions
#   source             = "../modules/redis_instance"
#   name               = "redis-${local.region_aliases[each.key]}-${var.environment}"
#   project            = var.project
#   region             = each.value
#   read_replicas_mode = "READ_REPLICAS_ENABLED"
#   memory_size_gb     = 5
#   replica_count      = 1


# }

module "notification_channels" {
  source      = "../modules/notification_channels"
  alert_email = "aishwaryasarath2025@gmail.com"
  project     = var.project
}
# module "redis_monitoring" {
#   for_each = local.regions

#   source      = "../modules/redis_monitoring"
#   project_id  = var.project
#   region      = each.value
#   environment = var.environment

#   # build the instance name exactly how you built it for redis_instance
#   redis_instance_id = "redis-${local.region_aliases[each.key]}-${var.environment}"

#   # if your module needs notification_channels or other vars, pass them too
# }
module "some_backup_bucket" {
  for_each      = local.regions
  source        = "../modules/backup_bucket"
  project       = var.project
  name          = "some-backup-${local.region_aliases[each.key]}-${var.environment}"
  location      = each.value
  storage_class = "STANDARD"
  versioning    = true
  force_destroy = false


}

module "gcs_monitoring" {
  for_each                 = module.some_backup_bucket
  source                   = "../modules/gcs_monitoring2"
  bucket_name              = each.value.bucket_name
  notification_channel_ids = [module.notification_channels.email_channel_id]
  project                  = var.project
  environment              = var.environment

}


# module "vertex_ai_monitoring" {
#   source                   = "../modules/vertex_ai_monitoring"
#   project_id               = var.project
#   notification_channel_ids = [module.notification_channels.email_channel_id]
#   environment              = "nonprod"

# }
