

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
      filter     = "resource.type = \"gcs_bucket\" AND resource.labels.bucket_name = \"${var.bucket_name}\" AND metric.type = \"storage.googleapis.com/api/request_count\" AND metric.labels.response_code = monitoring.regex.full_match(\"CANCELLED|INVALID_ARGUMENT|NOT_FOUND|ALREADY_EXISTS|PERMISSION_DENIED|UNAUTHENTICATED|RESOURCE_EXHAUSTED|FAILED_PRECONDITION|ABORTED|OUT_OF_RANGE\")"
      comparison = "COMPARISON_GT"
      duration   = "60s"
      #duration = "300s"
      #threshold_value = 10
      threshold_value = 5

      trigger {
        count = 1
      }

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }
    }
  }

  alert_strategy {
    auto_close           = "3600s"
    notification_prompts = ["OPENED"]
  }

  notification_channels = var.notification_channel_ids
}

resource "google_monitoring_alert_policy" "gcs_5xx_error" {
  project      = var.project
  display_name = "test gcs 5xx - ${var.bucket_name}"
  combiner     = "OR"
  enabled      = true
  severity     = "ERROR"

  documentation {
    content   = "4xx error alert for ${var.bucket_name} "
    mime_type = "text/markdown"
    subject   = "test- alert gcs 4xx manual"
  }

  conditions {
    display_name = "GCS Bucket - 5xx Request count"

    condition_threshold {
      filter     = "resource.type = \"gcs_bucket\" AND resource.labels.bucket_name = \"${var.bucket_name}\" AND metric.type = \"storage.googleapis.com/api/request_count\" AND metric.labels.response_code = monitoring.regex.full_match(\"INTERNAL|UNIMPLEMENTED|UNAVAILABLE|DATA_LOSS|DEADLINE_EXCEEDED|UNKNOWN\")"
      comparison = "COMPARISON_GT"
      duration   = "60s"
      #duration = "300s"
      threshold_value = 10

      trigger {
        count = 1
      }

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
        #group_by_fields = ["metric.label.response_code"]
      }
    }
  }

  alert_strategy {
    auto_close           = "3600s"
    notification_prompts = ["OPENED"]
  }

  notification_channels = var.notification_channel_ids
}

# main.tf
resource "google_monitoring_alert_policy" "secret_4xx_error" {
  display_name = "4xx secret manager request count"
  combiner     = "OR"
  enabled      = true
  severity     = "WARNING"

  documentation {
    content   = "test $${metric.label.response_code}."
    subject   = "test secret 4xx"
    mime_type = "text/markdown"
  }

  conditions {
    display_name = "4xx Secret Manager Request count"

    condition_threshold {
      filter = <<-EOT
        resource.type = "consumed_api"
        AND resource.labels.service = "secretmanager.googleapis.com"
        AND metric.type = "serviceruntime.googleapis.com/api/request_count"
        AND metric.labels.response_code_class = "4xx"
      EOT

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }

      comparison      = "COMPARISON_GT"
      threshold_value = 5
      duration        = "60s"
      #duration        = "300s"

      trigger {
        count = 1
      }
    }
  }

  alert_strategy {
    auto_close           = "1800s"
    notification_prompts = ["OPENED", "CLOSED"]
  }

  notification_channels = var.notification_channel_ids
}

resource "google_monitoring_alert_policy" "secret_5xx_error" {
  display_name = "5xx secret manager request count"
  combiner     = "OR"
  enabled      = true
  severity     = "WARNING"

  documentation {
    content   = "$${metric.label.response_code}."
    subject   = "secret 5xx"
    mime_type = "text/markdown"
  }

  conditions {
    display_name = "5xx Secret Manager Request count"

    condition_threshold {
      filter = <<-EOT
        resource.type = "consumed_api"
        AND resource.labels.service = "secretmanager.googleapis.com"
        AND metric.type = "serviceruntime.googleapis.com/api/request_count"
        AND metric.labels.response_code_class = "5xx"
      EOT

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }

      comparison      = "COMPARISON_GT"
      threshold_value = 5
      duration        = "60s"
      #duration        = "300s"

      trigger {
        count = 1
      }
    }
  }

  alert_strategy {
    auto_close           = "1800s"
    notification_prompts = ["OPENED", "CLOSED"]
  }

  notification_channels = var.notification_channel_ids
}

#for vertex ai
#resource.type="consumed_api" AND metric.type="serviceruntime.googleapis.com/api/request_count"  AND resource.labels.service="aiplatform.googleapis.com" AND metric.labels.response_code_class = "4xx")
resource "google_monitoring_alert_policy" "vertex_ai_4xx_error" {
  display_name = "4xx vertex ai request count"
  combiner     = "OR"
  enabled      = true
  severity     = "WARNING"

  documentation {
    content   = "$${metric.label.response_code}."
    subject   = "vertex ai 4xx"
    mime_type = "text/markdown"
  }

  conditions {
    display_name = "4xx vertex ai  Request count"

    condition_threshold {
      filter = <<-EOT
        resource.type = "consumed_api"
        AND resource.labels.service = "aiplatform.googleapis.com"
        AND metric.type = "serviceruntime.googleapis.com/api/request_count"
        AND metric.labels.response_code_class = "4xx"
      EOT

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }

      comparison      = "COMPARISON_GT"
      threshold_value = 5
      duration        = "60s"
      #duration        = "300s"

      trigger {
        count = 1
      }
    }
  }

  alert_strategy {
    auto_close           = "1800s"
    notification_prompts = ["OPENED", "CLOSED"]
  }

  notification_channels = var.notification_channel_ids
}

resource "google_monitoring_alert_policy" "vertex_ai_5xx_error" {
  display_name = "5xx vertex ai request count"
  combiner     = "OR"
  enabled      = true
  severity     = "WARNING"

  documentation {
    content   = "$${metric.label.response_code}."
    subject   = "vertex ai 5xx"
    mime_type = "text/markdown"
  }

  conditions {
    display_name = "5xx vertex ai Request count"

    condition_threshold {
      filter = <<-EOT
        resource.type = "consumed_api"
        AND resource.labels.service = "aiplatform.googleapis.com"
        AND metric.type = "serviceruntime.googleapis.com/api/request_count"
        AND metric.labels.response_code_class = "5xx"
      EOT

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }

      comparison      = "COMPARISON_GT"
      threshold_value = 5
      duration        = "60s"
      #duration        = "300s"

      trigger {
        count = 1
      }
    }
  }

  alert_strategy {
    auto_close           = "1800s"
    notification_prompts = ["OPENED", "CLOSED"]
  }

  notification_channels = var.notification_channel_ids
}
