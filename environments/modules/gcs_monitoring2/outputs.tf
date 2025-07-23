output "gcs_error_metric_names" {
  value = [for m in google_logging_metric.gcs_error_metrics : m.name]
}

output "gcs_error_alert_policy_names" {
  value = [for a in google_monitoring_alert_policy.gcs_error_alerts : a.display_name]
}

output "bucket_deletion_metric_name" {
  value = google_logging_metric.bucket_deletion_metric.name
}

output "bucket_deletion_alert_name" {
  value = google_monitoring_alert_policy.bucket_deletion_alert.display_name
}

output "unauthorized_access_metric_name" {
  value = google_logging_metric.unauthorized_access_metric.name
}

output "unauthorized_access_alert_name" {
  value = google_monitoring_alert_policy.gcs_unauthorized_access_alert.display_name
}
