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
  project  = var.project
  name     = "gcs_error_${each.key}-${var.bucket_name}"
  filter   = <<EOT
resource.type="gcs_bucket"
resource.labels.bucket_name="${var.bucket_name}"
protoPayload.status.code=${each.key}
EOT

  metric_descriptor {
    metric_kind  = "DELTA"
    value_type   = "INT64"
    unit         = "1"
    display_name = "GCS ${each.value} Error"
  }
}

# Create alert policies for each error type separately
resource "google_monitoring_alert_policy" "gcs_error_alerts" {
  for_each = local.gcs_error_conditions
  project  = var.project

  display_name = "GCS ${each.value} - ${var.bucket_name}"
  combiner     = "OR"
  enabled      = true
  severity     = local.gcs_alert_severity[each.key]
  depends_on = [
    google_logging_metric.gcs_error_metrics
  ]
  conditions {
    display_name = "GCS ${each.value} Error Detected"

    condition_threshold {
      filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_error_${each.key}-${var.bucket_name}\""
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
    content   = "GCS ${each.value} error detected in bucket `${var.bucket_name}`. This indicates a critical issue and may impact backup reliability."
    mime_type = "text/markdown"
  }

  notification_channels = var.notification_channel_ids
}


resource "google_logging_metric" "bucket_deletion_metric" {
  project = var.project

  name   = "gcs_bucket_deletion_count-${var.bucket_name}"
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
  project = var.project

  display_name = "GCS Bucket Deletion - ${var.bucket_name}"
  combiner     = "OR"
  enabled      = true
  severity     = "CRITICAL"

  depends_on = [
    google_logging_metric.bucket_deletion_metric
  ]

  conditions {
    display_name = "Bucket deletion detected"
    condition_threshold {
      filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_bucket_deletion_count-${var.bucket_name}\""
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
    subject   = "GCS Bucket Deletion Alert  - ${var.bucket_name}"
  }

  #notification_channels = [google_monitoring_notification_channel.email.id]
  notification_channels = var.notification_channel_ids

}

resource "google_logging_metric" "unauthorized_access_metric" {
  name    = "gcs_unauthorized_access_count_${var.bucket_name}"
  project = var.project

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
  project = var.project


  display_name = "gcs unauthorized access count - ${var.bucket_name}"
  combiner     = "OR"
  enabled      = true
  severity     = "ERROR"
  depends_on = [
    google_logging_metric.unauthorized_access_metric
  ]
  conditions {
    display_name = "GCS ${var.bucket_name} Unauthorized Access Detected"

    condition_threshold {
      filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_unauthorized_access_count_${var.bucket_name}\""
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
