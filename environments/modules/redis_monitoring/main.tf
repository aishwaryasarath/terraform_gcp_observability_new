


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

  #notification_channels = [google_monitoring_notification_channel.email.id]
  notification_channels = var.notification_channel_ids
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

  #notification_channels = [google_monitoring_notification_channel.email.id]
  notification_channels = var.notification_channel_ids
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

  #notification_channels = [google_monitoring_notification_channel.email.id]
  notification_channels = var.notification_channel_ids
}
