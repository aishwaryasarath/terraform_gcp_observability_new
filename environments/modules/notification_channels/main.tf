resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Alerts"
  type         = "email"
  labels = {
    email_address = var.alert_email
  }
}
