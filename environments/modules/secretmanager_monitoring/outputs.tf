output "secret_error_alert_policy_names" {
  description = "Map of Secret Manager error alert policy display names per error type"
  value = {
    for k, policy in google_monitoring_alert_policy.secret_error_alerts :
    k => policy.display_name
  }
}

output "secret_error_log_metric_names" {
  description = "Names of Secret Manager log-based error metrics"
  value = [
    for k in keys(google_logging_metric.secret_critical_errors) :
    google_logging_metric.secret_critical_errors[k].name
  ]
}

output "secret_excessive_access_alert_name" {
  description = "Display name of the Secret Manager excessive access alert policy"
  value       = google_monitoring_alert_policy.secret_manager_excessive_access.display_name
}

output "secret_deleted_alert_name" {
  description = "Display name of the Secret Manager secret deleted alert policy"
  value       = google_monitoring_alert_policy.secret_deleted_alert.display_name
}
