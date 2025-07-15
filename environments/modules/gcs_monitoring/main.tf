locals {
  gcs_error_conditions = {
    "13" = "INTERNAL_ERROR"      # 500
    "14" = "SERVICE_UNAVAILABLE" # 503
  }
  gcs_alert_severity = {
    "13" = "CRITICAL"
    "14" = "CRITICAL"
  }
}
# Log-based metrics
resource "google_logging_metric" "gcs_error_metrics" {
  for_each = local.gcs_error_conditions

  name   = "gcs_error_${each.key}"
  filter = <<EOT
resource.type="gcs_bucket"
resource.labels.bucket_name="${var.bucket_name}"
protoPayload.status.code=${each.key}
EOT

  metric_descriptor {
    metric_kind  = "DELTA"
    value_type   = "INT64"
    unit         = "1"
    display_name = "GCS ${each.value} Error (${each.key})"
  }
}

# Create alert policies for each error type separately
resource "google_monitoring_alert_policy" "gcs_error_alerts" {
  for_each     = local.gcs_error_conditions
  display_name = "GCS ${each.value} (${each.key}) - ${var.bucket_name}"
  combiner     = "OR"
  enabled      = true
  severity     = local.gcs_alert_severity[each.key]

  conditions {
    display_name = "GCS ${each.value} Error (${each.key}) Detected"

    condition_threshold {
      filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_error_${each.key}\""
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

  documentation {
    content   = "GCS ${each.value} error (${each.key}) detected in bucket `${var.bucket_name}`. This indicates a critical issue and may impact backup reliability."
    mime_type = "text/markdown"
  }

  notification_channels = var.notification_channel_ids
}


resource "google_logging_metric" "bucket_deletion_metric" {
  name   = "gcs_bucket_deletion_count"
  filter = <<EOT
resource.type="gcs_bucket"
protoPayload.methodName="storage.buckets.delete"
resource.labels.bucket_name="${var.bucket_name}"
EOT

  metric_descriptor {
    metric_kind  = "DELTA"
    value_type   = "INT64"
    unit         = "1"
    display_name = "GCS Bucket Deletion"
  }
}

resource "google_monitoring_alert_policy" "bucket_deletion_alert" {
  display_name = "GCS Bucket Deletion - ${var.bucket_name}"
  combiner     = "OR"
  enabled      = true
  severity     = "CRITICAL"

  conditions {
    display_name = "Bucket deletion detected"
    condition_threshold {
      filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_bucket_deletion_count\""
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

  documentation {
    content   = "GCS bucket `${var.bucket_name}` was deleted. Investigate immediately."
    mime_type = "text/markdown"
  }

  #notification_channels = [google_monitoring_notification_channel.email.id]
  notification_channels = var.notification_channel_ids

}

resource "google_logging_metric" "unauthorized_access_metric" {
  name   = "${var.bucket_name}_gcs_unauthorized_access_count"
  filter = <<EOT
resource.type="gcs_bucket"
protoPayload.authorizationInfo.permission="storage.objects.list"
protoPayload.authorizationInfo.granted="false"
resource.labels.bucket_name="${var.bucket_name}"
EOT

  metric_descriptor {
    metric_kind  = "DELTA"
    value_type   = "INT64"
    unit         = "1"
    display_name = "GCS Bucket Unauthorized Access"
  }
}

resource "google_monitoring_alert_policy" "gcs_unauthorized_access_alert" {

  display_name = "${var.bucket_name}_gcs_unauthorized_access_count"
  combiner     = "OR"
  enabled      = true
  severity     = "ERROR"

  conditions {
    display_name = "GCS ${var.bucket_name} Unauthorized Access Detected"

    condition_threshold {
      filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/${var.bucket_name}_gcs_unauthorized_access_count\""
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

  documentation {
    content   = "GCS bucket `${var.bucket_name}` unauthorized access detected. This may indicate a security breach or misconfiguration."
    mime_type = "text/markdown"
  }

  notification_channels = var.notification_channel_ids
}
