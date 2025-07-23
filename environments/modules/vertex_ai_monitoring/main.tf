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
    content   = "Route to fallback model"
    mime_type = "text/markdown"
  }
}

resource "google_monitoring_alert_policy" "vertex_ai_failure_rate" {
  project      = var.project_id
  display_name = "Vertex AI Failure Rate - ${var.environment}"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "5xx errors > 5% over 5 minutes"
    condition_threshold {
      filter          = <<EOT
resource.labels.service_name=\"aiplatform.googleapis.com\" AND protoPayload.status.code=14
EOT
      comparison      = "COMPARISON_GT"
      threshold_value = 0.05
      duration        = "300s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
      trigger { count = 1 }
    }
  }
  notification_channels = var.notification_channel_ids
  severity              = "CRITICAL"
  documentation {
    content   = "Trigger failover / auto-throttle"
    mime_type = "text/markdown"
  }
}

# resource "google_monitoring_alert_policy" "vertex_ai_quota_exhaustion" {
#   project      = var.project_id
#   display_name = "Vertex AI Quota Exhaustion - ${var.environment}"
#   combiner     = "OR"
#   enabled      = true

#   conditions {
#     display_name = "Quota > 90%"
#     condition_threshold {
#       filter          = "metric.type=\"serviceruntime.googleapis.com/quota/allocation/usage\" resource.type=\"consumer_quota\""
#       comparison      = "COMPARISON_GT"
#       threshold_value = 0.9
#       duration        = "60s"
#       trigger { count = 1 }
#     }
#   }
#   notification_channels = var.notification_channel_ids
#   severity              = "WARNING"
#   documentation {
#     content   = "Throttle gateway traffic"
#     mime_type = "text/markdown"
#   }
# }

# resource "google_monitoring_alert_policy" "high_cost_spike" {
#   project      = var.project_id
#   display_name = "High Cost Spike - ${var.environment}"
#   combiner     = "OR"
#   enabled      = true

#   conditions {
#     display_name = "Daily cost delta > 30%"
#     condition_threshold {
#       filter          = "metric.type=\"custom.googleapis.com/daily_cost_delta\""
#       comparison      = "COMPARISON_GT"
#       threshold_value = 0.3
#       duration        = "3600s"
#       trigger { count = 1 }
#     }
#   }
#   notification_channels = var.notification_channel_ids
#   severity              = "WARNING"
#   documentation {
#     content   = "Notify Finance / stop overuse"
#     mime_type = "text/markdown"
#   }
# }

# resource "google_monitoring_alert_policy" "no_inference_activity" {
#   project      = var.project_id
#   display_name = "No Inference Activity"
#   combiner     = "OR"
#   enabled      = true

#   conditions {
#     display_name = "Zero calls over 15 min"
#     condition_absent {
#       filter   = "metric.type=\"aiplatform.googleapis.com/prediction/online/prediction_requests\""
#       duration = "900s"
#       trigger { count = 1 }
#     }
#   }
#   notification_channels = var.notification_channel_ids
#   severity              = "WARNING"
#   documentation {
#     content   = "Check for routing issues"
#     mime_type = "text/markdown"
#   }
# }

# resource "google_logging_metric" "vertex_ai_403" {
#   name   = "vertex_ai_403_errors - ${var.environment}"
#   filter = "resource.type=\"aiplatform.googleapis.com/Endpoint\" AND protoPayload.status.code=403"
#   metric_descriptor {
#     metric_kind = "DELTA"
#     value_type  = "INT64"
#     unit        = "1"
#   }
# }

# resource "google_monitoring_alert_policy" "unauthorized_access_attempt" {
#   project      = var.project_id
#   display_name = "Unauthorized Access Attempt - ${var.environment}"
#   combiner     = "OR"
#   enabled      = true

#   conditions {
#     display_name = "403 errors from Vertex AI"
#     condition_threshold {
#       filter          = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.vertex_ai_403.name}\""
#       comparison      = "COMPARISON_GT"
#       threshold_value = 0
#       duration        = "60s"
#       trigger { count = 1 }
#     }
#   }
#   notification_channels = var.notification_channel_ids
#   severity              = "CRITICAL"
#   documentation {
#     content   = "Audit service account permissions"
#     mime_type = "text/markdown"
#   }
# }

# resource "google_monitoring_alert_policy" "model_endpoint_unavailable" {
#   project      = var.project_id
#   display_name = "Model Endpoint Unavailable - ${var.environment}"
#   combiner     = "OR"
#   enabled      = true

#   conditions {
#     display_name = "Health check failure"
#     condition_threshold {
#       filter          = "metric.type=\"aiplatform.googleapis.com/endpoint/online/predict_request_count\" resource.type=\"aiplatform.googleapis.com/Endpoint\""
#       comparison      = "COMPARISON_EQ"
#       threshold_value = 0
#       duration        = "60s"
#       trigger { count = 1 }
#     }
#   }
#   notification_channels = var.notification_channel_ids
#   severity              = "CRITICAL"
#   documentation {
#     content   = "Circuit break and failover"
#     mime_type = "text/markdown"
#   }
# }
