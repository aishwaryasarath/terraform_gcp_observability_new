
# #--------------custom --------------
# resource "google_logging_metric" "oom_errors" {
#   name    = "oom-errors-${var.environment}-${var.redis_instance_name}"
#   project = var.project_id
#   filter  = "resource.type=\"redis_instance\" resource.labels.instance_id = \"projects/${var.project_id}/locations/${var.region}/instances/${var.redis_instance_name}\" AND textPayload:\"OOM command not allowed\""
#   metric_descriptor {
#     metric_kind  = "DELTA"
#     value_type   = "INT64"
#     unit         = "1"
#     display_name = "Redis OOM Errors"
#   }
# }




resource "google_monitoring_alert_policy" "redis_eviction" {
  display_name = "eviction-${var.environment}-${var.redis_instance_name}"
  project      = var.project_id
  combiner     = "OR"
  enabled      = true
  severity     = "WARNING"
  alert_strategy {
    auto_close           = "21600s"
    notification_prompts = ["OPENED", "CLOSED"]
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
  # user_labels = {
  #   project_id    = var.project_id
  #   context       = "redis"
  #   instance_id   = var.redis_instance_name
  #   resource_type = "redis_instance"
  #   region        = var.region
  # }
  conditions {
    display_name = "Cloud Memorystore Redis Instance - Evicted Keys"

    condition_threshold {
      filter          = "resource.type = \"redis_instance\" resource.labels.instance_id = \"${var.redis_instance_id}\"  AND metric.type = \"redis.googleapis.com/stats/evicted_keys\""
      comparison      = "COMPARISON_GT"
      duration        = "0s"
      threshold_value = 1

      trigger {
        count = 1
      }

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
}

# resource "google_monitoring_alert_policy" "oom_error_alert" {
#   project      = var.project_id
#   display_name = "${var.redis_instance_name} - Redis OOM Error"
#   combiner     = "OR"
#   conditions {
#     display_name = "OOM Error > 0"
#     condition_threshold {
#       filter          = "resource.type=\"redis_instance\" resource.labels.instance_id = \"projects/${var.project_id}/locations/${var.region}/instances/${var.redis_instance_name}\" AND metric.type=\"logging.googleapis.com/user/oom_errors-${var.environment}-${var.redis_instance_name}\""
#       comparison      = "COMPARISON_GT"
#       threshold_value = 0
#       duration        = "60s"
#       trigger {
#         count = 1
#       }
#     }
#   }
#   # user_labels = {
#   #   project_id    = var.project_id
#   #   context       = "redis"
#   #   instance_id   = var.redis_instance_name
#   #   resource_type = "redis_instance"
#   #   region        = var.region
#   # }
#   notification_channels = [google_monitoring_notification_channel.email.id]
# }


resource "google_monitoring_notification_channel" "email" {
  project      = var.project_id
  display_name = "Email Alerts"
  type         = "email"
  labels = {
    email_address = "aishwaryasarath2025@gmail.com"
  }
}



# --------------from gcp --------------
resource "google_monitoring_alert_policy" "redis_memory_utilization" {
  project      = var.project_id
  display_name = "System Memory Utilization for ${var.environment} - ${var.redis_instance_name}"

  documentation {
    content   = "This alert fires if the system memory utilization is above the set threshold. The utilization is measured on a scale of 0 to 1."
    mime_type = "text/markdown"
  }

  combiner = "OR"
  enabled  = true
  severity = "CRITICAL"

  # user_labels = {

  #   region        = "us-central1"
  #   resource_type = "redis_instance"
  #   project_id    = "intense-reason-458522-h4"
  #   context       = "redis"
  # }

  conditions {
    display_name = "Cloud Memorystore Redis Instance - System Memory Usage Ratio"

    condition_threshold {
      filter = "resource.type = \"redis_instance\" AND resource.labels.instance_id = \"${var.redis_instance_id}\"  AND metric.type = \"redis.googleapis.com/stats/memory/system_memory_usage_ratio\""

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8

      trigger {
        count = 1
      }

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
}

resource "google_monitoring_alert_policy" "redis_cpu_utilization" {
  project      = var.project_id
  display_name = "CPU utilization for ${var.environment} - ${var.redis_instance_name}"
  severity     = "WARNING"

  documentation {
    content   = "This alert fires if the Redis Engine CPU Utilization goes above the set threshold. The utilization is measured on a scale of 0 to 1. "
    mime_type = "text/markdown"
  }

  combiner = "OR"
  enabled  = true

  # user_labels = {
  #   instance_id   = "dev-redis-instance"
  #   region        = "us-central1"
  #   resource_type = "redis_instance"
  #   project_id    = "intense-reason-458522-h4"
  #   context       = "redis"
  # }

  conditions {
    display_name = "Cloud Memorystore Redis Instance - Redis Engine CPU utilization"

    condition_threshold {
      filter = "resource.type = \"redis_instance\" AND resource.labels.instance_id = \"${var.redis_instance_id}\"  AND metric.type = \"redis.googleapis.com/stats/cpu_utilization_main_thread\""


      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.9

      trigger {
        count = 1
      }

      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["resource.label.instance_id", "resource.label.node_id"]
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
}
resource "google_monitoring_alert_policy" "redis_failover" {
  display_name = "Failover alert ${var.environment} - ${var.redis_instance_name}"
  project      = var.project_id

  documentation {
    content   = "This alert fires if failover occurs for a standard tier instance. To ensure that alerts always fire, we recommend keeping the threshold value to 0"
    mime_type = "text/markdown"
  }

  combiner = "OR"
  enabled  = true

  # user_labels = {
  #   project_id    = var.project_id
  #   context       = "redis"
  #   instance_id   = var.redis_instance_name
  #   resource_type = "redis_instance"
  #   region        = var.region
  # }
  severity = "ERROR"

  conditions {
    display_name = "Cloud Memorystore Redis Instance - Failover"

    condition_threshold {
      filter          = "resource.type = \"redis_instance\" AND  resource.labels.instance_id = \"${var.redis_instance_id}\"  AND metric.type = \"redis.googleapis.com/replication/role\""
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_COUNT"
      }

      trigger {
        count = 1
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
}
