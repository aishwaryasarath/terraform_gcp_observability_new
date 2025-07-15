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
}

module "bucket2" {
  source   = "../modules/gcs_bucket"
  name     = "aish-bucket-2-${var.project}"
  location = "US"
}

# module "redis_monitoring" {
#   source            = "../modules/redis_monitoring"
#   project_id        = var.project
#   redis_instance_id = module.redis_instance.instance_id
#   environment       = "dev"
#   region            = "us-central1"

# }

# module "redis_instance" {
#   source         = "../modules/redis_instance"
#   name           = "dev-redis-instance"
#   region         = "us-central1"
#   tier           = "STANDARD_HA"
#   memory_size_gb = 1
#   display_name   = "Dev Redis"
# }

module "gcs_monitoring" {
  source                   = "../modules/gcs_monitoring"
  bucket_name              = module.bucket2.bucket_name
  notification_channel_ids = [module.notification_channels.email_channel_id]

}

module "secretmanager_monitoring" {
  source                   = "../modules/secretmanager_monitoring"
  notification_channel_ids = [module.notification_channels.email_channel_id]

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
