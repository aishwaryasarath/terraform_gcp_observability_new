
# resource "google_monitoring_notification_channel" "email" {
#   display_name = "Email Alerts"
#   type         = "email"
#   labels = {
#     email_address = "aishwaryasarath2025@gmail.com"
#   }
# }



# AccessSecretVersion
resource "google_logging_metric" "secret_critical_errors" {
  for_each = {
    internal_error      = "resource.type=\"secretmanager.googleapis.com/Secret\" AND protoPayload.status.code=13"
    service_unavailable = "resource.type=\"secretmanager.googleapis.com/Secret\" AND protoPayload.status.code=14"
    permission_denied   = "resource.type=\"secretmanager.googleapis.com/Secret\" AND protoPayload.status.code=7"
    # unauthenticated     = "resource.type=\"secretmanager.googleapis.com/Secret\"AND protoPayload.status.code=16"
    # failed_precond      = "resource.type=\"secretmanager.googleapis.com/Secret\"AND protoPayload.status.code=9"
    excessive_access = "resource.type=\"audited_resource\" AND protoPayload.methodName=\"google.cloud.secretmanager.v1.SecretManagerService.AccessSecretVersion\""
  }

  name        = each.key
  description = "Log-based metric for ${each.key} in Secret Manager"
  filter      = each.value

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }

}

resource "google_monitoring_alert_policy" "secret_manager_excessive_access" {
  display_name = "test_secret_manager_excessive"
  combiner     = "OR"
  enabled      = true

  documentation {
    content   = "test doc"
    mime_type = "text/markdown"
    subject   = "test"
  }

  conditions {
    display_name = "Audited Resource - logging/user/excessive_access"

    condition_threshold {
      filter          = "resource.type = \"audited_resource\" AND metric.type = \"logging.googleapis.com/user/excessive_access\""
      duration        = "60s" #300s
      comparison      = "COMPARISON_GT"
      threshold_value = 20

      trigger {
        count = 1
      }

      aggregations {
        alignment_period     = "60s" #600s
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_SUM"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s" # 7 days

    notification_prompts = ["OPENED"]
  }

  #notification_channels = [google_monitoring_notification_channel.email.id]
  notification_channels = var.notification_channel_ids
}





resource "google_monitoring_alert_policy" "secret_error_alerts" {
  for_each = {
    internal_error      = "logging.googleapis.com/user/internal_error"
    service_unavailable = "logging.googleapis.com/user/service_unavailable"
    permission_denied   = "logging.googleapis.com/user/permission_denied"
    # unauthenticated     = "logging.googleapis.com/user/unauthenticated"
    # failed_precond      = "logging.googleapis.com/user/failed_precond"
  }

  display_name = "Secret Manager - ${each.key} Alert"
  combiner     = "OR"

  conditions {
    display_name = "${each.key} rate"
    condition_threshold {
      filter          = "resource.type=\"secretmanager.googleapis.com/Secret\" AND metric.type=\"${each.value}\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 1
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
}

resource "google_monitoring_alert_policy" "secret_deleted_alert" {
  display_name = "Secret Manager - Secret Deleted"

  combiner = "OR"
  severity = "CRITICAL"

  conditions {
    display_name = "Secret Deleted"
    condition_matched_log {
      filter = "resource.type=\"audited_resource\" AND protoPayload.methodName=\"google.cloud.secretmanager.v1.SecretManagerService.DeleteSecret\""
    }
  }
  notification_channels = var.notification_channel_ids
  #fication_channels = [google_monitoring_notification_channel.email.id]
  documentation {
    content   = "A secret was deleted from Secret Manager."
    mime_type = "text/markdown"
  }
  alert_strategy {
    notification_rate_limit {
      period = "3600s" # limit notifications to at most one per hour
    }
    auto_close = "86400s"
  }

}
