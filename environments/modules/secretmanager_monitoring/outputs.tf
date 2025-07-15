# output "secret_alert_policy_names" {
#   value = [
#     for ap in merge(
#       google_monitoring_alert_policy.secret_error_alerts,
#       {
#         #deleted      = google_monitoring_alert_policy.secret_deleted_alert,
#         access_alert = google_monitoring_alert_policy.excessive_access_alert
#       }
#     ) : ap.name
#   ]
# }
