output "gcs_error_metric_names" {
  value = {
    for k, m in module.gcs_monitoring :
    k => m.gcs_error_metric_names
  }
}

output "gcs_error_alert_policy_names" {
  value = {
    for k, m in module.gcs_monitoring :
    k => m.gcs_error_alert_policy_names
  }
}

output "bucket_deletion_metric_name" {
  value = {
    for k, m in module.gcs_monitoring :
    k => m.bucket_deletion_metric_name
  }
}

output "bucket_deletion_alert_name" {
  value = {
    for k, m in module.gcs_monitoring :
    k => m.bucket_deletion_alert_name
  }
}

output "unauthorized_access_metric_name" {
  value = {
    for k, m in module.gcs_monitoring :
    k => m.unauthorized_access_metric_name
  }
}

output "unauthorized_access_alert_name" {
  value = {
    for k, m in module.gcs_monitoring :
    k => m.unauthorized_access_alert_name
  }
}
