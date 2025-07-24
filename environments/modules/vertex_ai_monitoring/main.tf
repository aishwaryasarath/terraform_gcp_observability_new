
resource "google_monitoring_alert_policy" "high_vertex_ai_latency" {
  project      = var.project_id
  display_name = "High Vertex AI Latency - ${var.environment}"
  combiner     = "OR"
  enabled      = true

  conditions {

    display_name = "Latency > 2000ms"
    condition_threshold {
      filter          = "metric.type=\"aiplatform.googleapis.com/prediction/online/prediction_latencies\" resource.type=\"aiplatform.googleapis.com/Endpoint\""
      comparison      = "COMPARISON_GT"
      threshold_value = 2000
      duration        = "60s"
      trigger { count = 1 }
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_PERCENTILE_99"
      }
    }

  }

  notification_channels = var.notification_channel_ids
  severity              = "WARNING"
  documentation {
    content   = "update this"
    mime_type = "text/markdown"
  }
}

resource "google_logging_metric" "vertex_ai_critical_errors" {
  for_each = {
    service_unavailable = "resource.type=\"audited_resource\" AND protoPayload.serviceName=\"aiplatform.googleapis.com\" AND protoPayload.status.code=14"
    internal_error      = "resource.type=\"audited_resource\" AND protoPayload.serviceName=\"aiplatform.googleapis.com\" AND protoPayload.status.code=13"
    permission_denied   = "resource.type=\"audited_resource\" AND protoPayload.serviceName=\"aiplatform.googleapis.com\" AND protoPayload.status.code=7"
  }

  name    = "vertex_ai_${each.key}"
  filter  = each.value
  project = var.project_id


  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }

}

resource "google_monitoring_alert_policy" "vertex_ai_error_alerts" {
  for_each = {
    internal_error      = "logging.googleapis.com/user/vertex_ai_internal_error"
    service_unavailable = "logging.googleapis.com/user/vertex_ai_service_unavailable"
    permission_denied   = "logging.googleapis.com/user/vertex_ai_permission_denied"
  }

  depends_on = [
    google_logging_metric.vertex_ai_critical_errors
  ]

  display_name = "Vertex AI - ${each.key} Alert"
  combiner     = "OR"

  conditions {
    display_name = "${each.key} rate"
    condition_threshold {
      filter          = "resource.type=\"audited_resource\"  AND metric.type=\"${each.value}\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 1
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = var.notification_channel_ids

  documentation {
    content   = "Vertex AI encountered ${each.key} errors."
    mime_type = "text/markdown"
  }

  user_labels = {
    severity = "critical"
  }

  enabled = true
}
