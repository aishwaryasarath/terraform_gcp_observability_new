

resource "google_logging_metric" "secret_critical_errors" {
  for_each = {
    internal_error      = "resource.type=\"secretmanager.googleapis.com/Secret\" AND protoPayload.status.code=13"
    service_unavailable = "resource.type=\"secretmanager.googleapis.com/Secret\" AND protoPayload.status.code=14"
    excessive_access    = "resource.type=\"audited_resource\" AND protoPayload.methodName=\"google.cloud.secretmanager.v1.SecretManagerService.AccessSecretVersion\""
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
  display_name = "secret_manager_excessive_access"
  combiner     = "OR"
  enabled      = true

  depends_on = [
    google_logging_metric.secret_critical_errors
  ]

  documentation {
    content   = <<-EOT
    A secret version has been accessed excessively. This may indicate a potential security issue or misconfiguration.
    For detailed investigation, check this runbook link: insert link here
  EOT
    mime_type = "text/markdown"
    subject   = "secret excessive access"
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

  notification_channels = var.notification_channel_ids
}





resource "google_monitoring_alert_policy" "secret_error_alerts" {
  for_each = {
    internal_error      = "logging.googleapis.com/user/internal_error"
    service_unavailable = "logging.googleapis.com/user/service_unavailable"
  }
  depends_on = [
    google_logging_metric.secret_critical_errors
  ]
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
  documentation {
    content   = "A secret was deleted from Secret Manager. For detailed investigation, check this runbook link: insert link here"
    mime_type = "text/markdown"
  }
  alert_strategy {
    notification_rate_limit {
      period = "3600s" # limit notifications to at most one per hour
    }
    auto_close = "86400s"
  }

}
resource "google_logging_metric" "secret_unauthorized_access_metric" {
  name   = "secret_unauthorized_access_count"
  filter = <<EOT
resource.type="audited_resource"
protoPayload.authorizationInfo.permission="secretmanager.versions.access"
protoPayload.authorizationInfo.granted="false"
EOT

  metric_descriptor {
    metric_kind  = "DELTA"
    value_type   = "INT64"
    unit         = "1"
    display_name = "Secret Unauthorized Access"
  }
}

resource "google_monitoring_alert_policy" "gcs_unauthorized_access_alert" {

  display_name = "secret_unauthorized_access_count"
  combiner     = "OR"
  enabled      = true
  severity     = "ERROR"

  depends_on = [
    google_logging_metric.secret_unauthorized_access_metric
  ]

  conditions {
    display_name = "Secret Unauthorized Access attempt Detected"

    condition_threshold {
      filter          = "resource.type=\"audited_resource\" AND metric.type=\"logging.googleapis.com/user/secret_unauthorized_access_count\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }

      trigger {
        count = 1
      }
    }
  }
}
