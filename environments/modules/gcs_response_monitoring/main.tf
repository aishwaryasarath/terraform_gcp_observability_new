

resource "google_monitoring_alert_policy" "gcs_500_error" {
  project      = var.project
  display_name = "test gcs 500 - ${var.bucket_name}"
  combiner     = "OR"
  enabled      = true
  severity     = "ERROR"

  documentation {
    content   = "test ${var.bucket_name}"
    mime_type = "text/markdown"
    subject   = "test- alert gcs manual"
  }

  conditions {
    display_name = "GCS Bucket - Request count"

    condition_threshold {
      filter          = "resource.type = \"gcs_bucket\" AND resource.labels.bucket_name = \"${var.bucket_name}\" AND metric.type = \"storage.googleapis.com/api/request_count\" AND metric.labels.response_code = monitoring.regex.full_match(\"INTERNAL|UNIMPLEMENTED|UNAVAILABLE|DATA_LOSS|DEADLINE_EXCEEDED|UNKNOWN\")"
      comparison      = "COMPARISON_GT"
      duration        = "0s"
      threshold_value = 5

      trigger {
        count = 1
      }

      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["metric.label.response_code"]
      }
    }
  }

  alert_strategy {
    auto_close           = "3600s"
    notification_prompts = ["OPENED"]
  }

  notification_channels = var.notification_channel_ids
}

resource "google_monitoring_alert_policy" "gcs_4xx_error" {
  project      = var.project
  display_name = "test gcs 4xx - ${var.bucket_name}"
  combiner     = "OR"
  enabled      = true
  severity     = "ERROR"

  documentation {
    content   = "4xx error alert for ${var.bucket_name} "
    mime_type = "text/markdown"
    subject   = "test- alert gcs 4xx manual"
  }

  conditions {
    display_name = "GCS Bucket - 4xx Request count"

    condition_threshold {
      filter          = "resource.type = \"gcs_bucket\" AND resource.labels.bucket_name = \"${var.bucket_name}\" AND metric.type = \"storage.googleapis.com/api/request_count\" AND metric.labels.response_code = monitoring.regex.full_match(\"CANCELLED|INVALID_ARGUMENT|NOT_FOUND|ALREADY_EXISTS|PERMISSION_DENIED|UNAUTHENTICATED|RESOURCE_EXHAUSTED|FAILED_PRECONDITION|ABORTED|OUT_OF_RANGE\")"
      comparison      = "COMPARISON_GT"
      duration        = "0s"
      threshold_value = 1

      trigger {
        count = 1
      }

      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["metric.label.response_code"]
      }
    }
  }

  alert_strategy {
    auto_close           = "3600s"
    notification_prompts = ["OPENED"]
  }

  notification_channels = var.notification_channel_ids
}
