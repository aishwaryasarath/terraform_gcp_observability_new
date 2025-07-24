# module "instance" {
#   source        = "../modules/compute_instance"
#   instance_name = "my-vm"
#   machine_type  = "e2-medium"
#   zone          = var.zone
#   image         = "debian-cloud/debian-12"
#   tags          = ["web", "dev"]
# }


module "bucket1" {
  source   = "../modules/gcs_bucket"
  name     = "aish-bucket-1-${var.project}"
  location = "US"
  project  = var.project
}

module "bucket2" {
  source   = "../modules/gcs_bucket"
  name     = "aish-bucket-2-${var.project}"
  location = "US"
  project  = var.project
}

# module "redis_monitoring" {
#   source              = "../modules/redis_monitoring"
#   project_id          = var.project
#   redis_instance_name = module.redis_instance.redis_instance_name
#   environment         = "dev"
#   region              = var.region

# }

# module "redis_instance" {
#   source         = "../modules/redis_instance"
#   name           = "redis-ue1-${var.environment}"
#   region         = var.region
#   tier           = "STANDARD_HA"
#   memory_size_gb = 5
#   display_name   = "Dev Redis"
# }

module "gcs_monitoring" {
  source                   = "../modules/gcs_monitoring"
  bucket_name              = module.bucket2.bucket_name
  notification_channel_ids = [module.notification_channels.email_channel_id]

}

# module "secretmanager_monitoring" {
#   source                   = "../modules/secretmanager_monitoring"
#   notification_channel_ids = [module.notification_channels.email_channel_id]

# }


module "vertex_ai_monitoring" {
  source                   = "../modules/vertex_ai_monitoring"
  project_id               = var.project
  notification_channel_ids = [module.notification_channels.email_channel_id]
  environment              = "dev"

}

resource "google_project_iam_audit_config" "gcs_audit" {
  project = var.project

  service = "storage.googleapis.com"

  audit_log_config {
    log_type = "DATA_READ"
  }

  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

resource "google_project_iam_audit_config" "secretmanager_audit" {
  project = var.project
  service = "secretmanager.googleapis.com"

  audit_log_config {
    log_type = "DATA_READ"
  }

  audit_log_config {
    log_type = "ADMIN_READ"
  }
}

module "notification_channels" {
  source      = "../modules/notification_channels"
  alert_email = "aishwaryasarath2025@gmail.com"
}

# module "redis_cluster" {
#   source        = "../modules/redis_cluster"
#   name          = "dev-redis-cluster"
#   region        = "us-central1"
#   shard_count   = 2
#   replica_count = 1


# }

module "some_backup_bucket" {
  source   = "../modules/backup_bucket"
  name     = "some-backup-bucket-${var.region_code}-${var.environment}"
  project  = var.project
  location = "US"

  storage_class = "STANDARD"
  versioning    = true
  force_destroy = false

}
# GCS does not have to work on dev env.

# make vertex ai work in all envs
# SM works on all envs
# confirm redis monitoring works on all envs
