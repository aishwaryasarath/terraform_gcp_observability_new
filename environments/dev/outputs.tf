# output "instance_name" {
#   value = module.instance.instance_name
# }

output "bucket1_url" {
  value = module.bucket1.bucket_url
}

output "bucket2_url" {
  value = module.bucket2.bucket_url
}

output "bucket2_name" {
  value = module.bucket2.bucket_name

}


output "redis_alert_policy_ids" {
  value = module.redis_monitoring.alert_policy_ids
}

output "redis_alert_policy_names" {
  value = module.redis_monitoring.alert_policy_names
}

# output "redis_oom_logging_metric" {
#   value = module.redis_monitoring.oom_logging_metric_name
# }

output "gcs_alert_policy_names" {
  description = "Map of GCS alert policy display names per error code"
  value       = module.gcs_monitoring.gcs_error_alert_policy_names
}

output "gcs_alert_policy_ids" {
  description = "Map of GCS alert policy IDs per error code"
  value       = module.gcs_monitoring.gcs_error_alert_policy_ids
}

output "gcs_log_metric_names" {
  description = "List of GCS error log-based metric names"
  value       = module.gcs_monitoring.gcs_error_log_metric_names
}

output "gcs_log_metric_display_names" {
  description = "List of GCS error log-based metric display names"
  value       = module.gcs_monitoring.gcs_error_log_metric_display_names
}

output "gcs_notification_channel_id" {
  description = "Notification channel ID used for GCS alerts"
  value       = module.notification_channels.email_channel_id
}


output "secret_alert_policy_names" {
  description = "Map of Secret Manager alert policy display names per error type"
  value       = module.secretmanager_monitoring.secret_error_alert_policy_names
}


output "secret_log_metric_names" {
  description = "List of Secret Manager error log-based metric names"
  value       = module.secretmanager_monitoring.secret_error_log_metric_names
}


output "secret_excessive_access_alert_name" {
  description = "Alert policy display name for excessive access in Secret Manager"
  value       = module.secretmanager_monitoring.secret_excessive_access_alert_name
}

output "secret_deleted_alert_name" {
  description = "Alert policy display name for secret deletion in Secret Manager"
  value       = module.secretmanager_monitoring.secret_deleted_alert_name
}

output "redis_instance_id" {
  description = "ID of the Redis instance created"
  value       = module.redis_instance.instance_id
}
