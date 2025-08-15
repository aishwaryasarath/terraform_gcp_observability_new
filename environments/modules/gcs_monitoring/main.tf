# locals {
#   gcs_error_conditions = {
#     "13" = "INTERNAL_ERROR"      # 500
#     "14" = "SERVICE_UNAVAILABLE" # 503
#   }
#   gcs_alert_severity = {
#     "13" = "CRITICAL"
#     "14" = "CRITICAL"
#   }
# }
# # Log-based metrics
# resource "google_logging_metric" "gcs_error_metrics" {
#   for_each = local.gcs_error_conditions

#   name   = "gcs_error_${each.key}"
#   filter = <<EOT
# resource.type="gcs_bucket"
# resource.labels.bucket_name="${var.bucket_name}"
# protoPayload.status.code=${each.key}
# EOT

#   metric_descriptor {
#     metric_kind  = "DELTA"
#     value_type   = "INT64"
#     unit         = "1"
#     display_name = "GCS ${each.value} Error (${each.key})"
#   }
# }

# # Create alert policies for each error type separately
# resource "google_monitoring_alert_policy" "gcs_error_alerts" {
#   for_each     = local.gcs_error_conditions
#   display_name = "GCS ${each.value} (${each.key}) - ${var.bucket_name}"
#   combiner     = "OR"
#   enabled      = true
#   severity     = local.gcs_alert_severity[each.key]
#   depends_on = [
#     google_logging_metric.gcs_error_metrics
#   ]
#   conditions {
#     display_name = "GCS ${each.value} Error (${each.key}) Detected"

#     condition_threshold {
#       filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_error_${each.key}\""
#       comparison      = "COMPARISON_GT"
#       threshold_value = 0
#       duration        = "0s"

#       aggregations {
#         alignment_period   = "60s"
#         per_series_aligner = "ALIGN_DELTA"
#       }

#       trigger {
#         count = 1
#       }
#     }
#   }

#   documentation {
#     content   = "GCS ${each.value} error (${each.key}) detected in bucket `${var.bucket_name}`. This indicates a critical issue and may impact backup reliability."
#     mime_type = "text/markdown"
#   }

#   notification_channels = var.notification_channel_ids
# }


# resource "google_logging_metric" "bucket_deletion_metric" {
#   name   = "gcs_bucket_deletion_count"
#   filter = <<EOT
# resource.type="gcs_bucket"
# protoPayload.methodName="storage.buckets.delete"
# resource.labels.bucket_name="${var.bucket_name}"
# EOT

#   metric_descriptor {
#     metric_kind  = "DELTA"
#     value_type   = "INT64"
#     unit         = "1"
#     display_name = "GCS Bucket Deletion"
#   }
# }

# resource "google_monitoring_alert_policy" "bucket_deletion_alert" {
#   display_name = "GCS Bucket Deletion - ${var.bucket_name}"
#   combiner     = "OR"
#   enabled      = true
#   severity     = "CRITICAL"

#   depends_on = [
#     google_logging_metric.bucket_deletion_metric
#   ]

#   conditions {
#     display_name = "Bucket deletion detected"
#     condition_threshold {
#       filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_bucket_deletion_count\""
#       comparison      = "COMPARISON_GT"
#       threshold_value = 0
#       duration        = "0s"

#       aggregations {
#         alignment_period   = "60s"
#         per_series_aligner = "ALIGN_DELTA"
#       }

#       trigger {
#         count = 1
#       }
#     }
#   }

#   documentation {
#     content   = "GCS bucket `${var.bucket_name}` was deleted. Investigate immediately."
#     mime_type = "text/markdown"
#   }

#   #notification_channels = [google_monitoring_notification_channel.email.id]
#   notification_channels = var.notification_channel_ids

# }

# resource "google_logging_metric" "unauthorized_access_metric" {
#   name   = "${var.bucket_name}_gcs_unauthorized_access_count"
#   filter = <<EOT
# resource.type="gcs_bucket"
# protoPayload.authorizationInfo.permission="storage.objects.list"
# protoPayload.authorizationInfo.granted="false"
# resource.labels.bucket_name="${var.bucket_name}"
# EOT

#   metric_descriptor {
#     metric_kind  = "DELTA"
#     value_type   = "INT64"
#     unit         = "1"
#     display_name = "GCS Bucket Unauthorized Access"
#   }
# }

# resource "google_monitoring_alert_policy" "gcs_unauthorized_access_alert" {

#   display_name = "${var.bucket_name}_gcs_unauthorized_access_count"
#   combiner     = "OR"
#   enabled      = true
#   severity     = "ERROR"
#   depends_on = [
#     google_logging_metric.unauthorized_access_metric
#   ]
#   conditions {
#     display_name = "GCS ${var.bucket_name} Unauthorized Access Detected"

#     condition_threshold {
#       filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/${var.bucket_name}_gcs_unauthorized_access_count\""
#       comparison      = "COMPARISON_GT"
#       threshold_value = 0
#       duration        = "0s"

#       aggregations {
#         alignment_period   = "60s"
#         per_series_aligner = "ALIGN_DELTA"
#       }

#       trigger {
#         count = 1
#       }
#     }
#   }

#   documentation {
#     content   = "GCS bucket `${var.bucket_name}` unauthorized access detected. This may indicate a security breach or misconfiguration."
#     mime_type = "text/markdown"
#   }

#   notification_channels = var.notification_channel_ids
# }

# locals {
#   gcs_error_conditions = {
#     "13" = "INTERNAL_ERROR"      # 500
#     "14" = "SERVICE_UNAVAILABLE" # 503
#   }
#   gcs_alert_severity = {
#     "13" = "CRITICAL"
#     "14" = "CRITICAL"
#   }
# }
# # Log-based metrics
# resource "google_logging_metric" "gcs_error_metrics" {
#   for_each = local.gcs_error_conditions

#   name   = "gcs_error_${each.key}"
#   filter = <<EOT
# resource.type="gcs_bucket"
# resource.labels.bucket_name="${var.bucket_name}"
# protoPayload.status.code=${each.key}
# EOT

#   metric_descriptor {
#     metric_kind  = "DELTA"
#     value_type   = "INT64"
#     unit         = "1"
#     display_name = "GCS ${each.value} Error (${each.key})"
#   }
# }

# # Create alert policies for each error type separately
# resource "google_monitoring_alert_policy" "gcs_error_alerts" {
#   for_each     = local.gcs_error_conditions
#   display_name = "GCS ${each.value} (${each.key}) - ${var.bucket_name}"
#   combiner     = "OR"
#   enabled      = true
#   severity     = local.gcs_alert_severity[each.key]
#   depends_on = [
#     google_logging_metric.gcs_error_metrics
#   ]
#   conditions {
#     display_name = "GCS ${each.value} Error (${each.key}) Detected"

#     condition_threshold {
#       filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_error_${each.key}\""
#       comparison      = "COMPARISON_GT"
#       threshold_value = 0
#       duration        = "0s"

#       aggregations {
#         alignment_period   = "60s"
#         per_series_aligner = "ALIGN_DELTA"
#       }

#       trigger {
#         count = 1
#       }
#     }
#   }

#   documentation {
#     content   = "GCS ${each.value} error (${each.key}) detected in bucket `${var.bucket_name}`. This indicates a critical issue and may impact backup reliability."
#     mime_type = "text/markdown"
#   }

#   notification_channels = var.notification_channel_ids
# }


# resource "google_logging_metric" "bucket_deletion_metric" {
#   name   = "gcs_bucket_deletion_count"
#   filter = <<EOT
# resource.type="gcs_bucket"
# protoPayload.methodName="storage.buckets.delete"
# resource.labels.bucket_name="${var.bucket_name}"
# EOT

#   metric_descriptor {
#     metric_kind  = "DELTA"
#     value_type   = "INT64"
#     unit         = "1"
#     display_name = "GCS Bucket Deletion"
#   }
# }

# resource "google_monitoring_alert_policy" "bucket_deletion_alert" {
#   display_name = "GCS Bucket Deletion - ${var.bucket_name}"
#   combiner     = "OR"
#   enabled      = true
#   severity     = "CRITICAL"

#   depends_on = [
#     google_logging_metric.bucket_deletion_metric
#   ]

#   conditions {
#     display_name = "Bucket deletion detected"
#     condition_threshold {
#       filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_bucket_deletion_count\""
#       comparison      = "COMPARISON_GT"
#       threshold_value = 0
#       duration        = "0s"

#       aggregations {
#         alignment_period   = "60s"
#         per_series_aligner = "ALIGN_DELTA"
#       }

#       trigger {
#         count = 1
#       }
#     }
#   }

#   documentation {
#     content   = "GCS bucket `${var.bucket_name}` was deleted. Investigate immediately."
#     mime_type = "text/markdown"
#   }

#   #notification_channels = [google_monitoring_notification_channel.email.id]
#   notification_channels = var.notification_channel_ids

# }

# resource "google_logging_metric" "unauthorized_access_metric" {
#   name   = "${var.bucket_name}_gcs_unauthorized_access_count"
#   filter = <<EOT
# resource.type="gcs_bucket"
# protoPayload.authorizationInfo.permission="storage.objects.list"
# protoPayload.authorizationInfo.granted="false"
# resource.labels.bucket_name="${var.bucket_name}"
# EOT

#   metric_descriptor {
#     metric_kind  = "DELTA"
#     value_type   = "INT64"
#     unit         = "1"
#     display_name = "GCS Bucket Unauthorized Access"
#   }
# }

# resource "google_monitoring_alert_policy" "gcs_unauthorized_access_alert" {

#   display_name = "${var.bucket_name}_gcs_unauthorized_access_count"
#   combiner     = "OR"
#   enabled      = true
#   severity     = "ERROR"
#   depends_on = [
#     google_logging_metric.unauthorized_access_metric
#   ]
#   conditions {
#     display_name = "GCS ${var.bucket_name} Unauthorized Access Detected"

#     condition_threshold {
#       filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/${var.bucket_name}_gcs_unauthorized_access_count\""
#       comparison      = "COMPARISON_GT"
#       threshold_value = 0
#       duration        = "0s"

#       aggregations {
#         alignment_period   = "60s"
#         per_series_aligner = "ALIGN_DELTA"
#       }

#       trigger {
#         count = 1
#       }
#     }
#   }

#   documentation {
#     content   = "GCS bucket `${var.bucket_name}` unauthorized access detected. This may indicate a security breach or misconfiguration."
#     mime_type = "text/markdown"
#   }

#   notification_channels = var.notification_channel_ids
# }

locals {
  gcs_4xx_errors = {
    "3"  = "BAD_REQUEST"           # 400
    "16" = "UNAUTHORIZED"          # 401
    "7"  = "FORBIDDEN"             # 403
    "5"  = "NOT_FOUND"             # 404
    "6"  = "CONFLICT"              # 409
    "8"  = "TOO_MANY_REQUESTS"     # 429
    "1"  = "CLIENT_CLOSED_REQUEST" # 499
  }

  gcs_5xx_errors = {
    "13" = "INTERNAL_SERVER_ERROR" # 500
    "12" = "NOT_IMPLEMENTED"       # 501
    "14" = "SERVICE_UNAVAILABLE"   # 503
    "4"  = "GATEWAY_TIMEOUT"       # 504
  }
}

resource "google_logging_metric" "gcs_4xx_metrics" {
  for_each = local.gcs_4xx_errors

  name   = "gcs_4xx_${each.key}"
  filter = <<EOT
  resource.type="gcs_bucket"
  resource.labels.bucket_name="${var.bucket_name}"
  protoPayload.status.code=${each.key}
  EOT

  metric_descriptor {
    metric_kind  = "DELTA"
    value_type   = "INT64"
    unit         = "1"
    display_name = "GCS 4xx Error ${each.value} (${each.key})"
  }
}

resource "google_logging_metric" "gcs_5xx_metrics" {
  for_each = local.gcs_5xx_errors

  name   = "gcs_5xx_${each.key}"
  filter = <<EOT
  resource.type="gcs_bucket"
  resource.labels.bucket_name="${var.bucket_name}"
  protoPayload.status.code=${each.key}
  EOT

  metric_descriptor {
    metric_kind  = "DELTA"
    value_type   = "INT64"
    unit         = "1"
    display_name = "GCS 5xx Error ${each.value} (${each.key})"
  }
}

resource "google_monitoring_alert_policy" "gcs_4xx_alert" {
  display_name = "GCS 4xx Errors - ${var.bucket_name}"
  combiner     = "OR"
  enabled      = true
  severity     = "ERROR"

  #depends_on = [for k in keys(local.gcs_4xx_errors) : google_logging_metric.gcs_4xx_metrics[k]]

  documentation {
    content   = "One or more 4xx errors detected in bucket `${var.bucket_name}`. Each condition corresponds to a specific HTTP client error."
    mime_type = "text/markdown"
  }

  notification_channels = var.notification_channel_ids

  # Conditions per 4xx
  conditions {
    display_name = "400 BAD_REQUEST"
    condition_threshold {
      filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_4xx_400\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }
      trigger { count = 1 }
    }
  }

  conditions {
    display_name = "401 UNAUTHORIZED"
    condition_threshold {
      filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_4xx_401\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }
      trigger { count = 1 }
    }
  }

  conditions {
    display_name = "403 FORBIDDEN"
    condition_threshold {
      filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_4xx_403\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }
      trigger { count = 1 }
    }
  }

  conditions {
    display_name = "404 NOT_FOUND"
    condition_threshold {
      filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_4xx_404\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }
      trigger { count = 1 }
    }
  }

  conditions {
    display_name = "409 CONFLICT"
    condition_threshold {
      filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_4xx_409\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }
      trigger { count = 1 }
    }
  }

  conditions {
    display_name = "429 TOO_MANY_REQUESTS"
    condition_threshold {
      filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_4xx_429\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }
      trigger { count = 1 }
    }
  }

  conditions {
    display_name = "499 CLIENT_CLOSED_REQUEST"
    condition_threshold {
      filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_4xx_499\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }
      trigger { count = 1 }
    }
  }
}

resource "google_monitoring_alert_policy" "gcs_5xx_alert" {
  display_name = "GCS 5xx Errors - ${var.bucket_name}"
  combiner     = "OR"
  enabled      = true
  severity     = "CRITICAL"

  #depends_on = [for k in keys(local.gcs_5xx_errors) : google_logging_metric.gcs_5xx_metrics[k]]

  documentation {
    content   = "One or more 5xx errors detected in bucket `${var.bucket_name}`. Each condition corresponds to a specific server-side error."
    mime_type = "text/markdown"
  }

  notification_channels = var.notification_channel_ids

  conditions {
    display_name = "500 INTERNAL_SERVER_ERROR"
    condition_threshold {
      filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_5xx_500\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }
      trigger { count = 1 }
    }
  }

  conditions {
    display_name = "501 NOT_IMPLEMENTED"
    condition_threshold {
      filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_5xx_501\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }
      trigger { count = 1 }
    }
  }

  conditions {
    display_name = "503 SERVICE_UNAVAILABLE"
    condition_threshold {
      filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_5xx_503\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }
      trigger { count = 1 }
    }
  }

  conditions {
    display_name = "504 GATEWAY_TIMEOUT"
    condition_threshold {
      filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/gcs_5xx_504\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }
      trigger { count = 1 }
    }
  }
}

