# variables.tf
variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "Redis region (e.g., us-central1)"
}

variable "instance_id" {
  type        = string
  description = "Redis instance ID (short name, e.g., test-cluster)"
}

variable "notification_channel_ids" {
  type        = list(string)
  description = "List of Monitoring notification channel resource IDs"
}

# main.tf
locals {
  # Full resource path expected by the filter
  redis_instance_path = "projects/${var.project_id}/locations/${var.region}/instances/${var.instance_id}"
}

resource "google_monitoring_alert_policy" "redis_standard_failover" {
  project      = var.project_id
  display_name = "Cloud Redis - Standard Instance Failover for ${var.instance_id}(${var.region})"
  combiner     = "OR"
  enabled      = true

  documentation {
    content   = "This alert fires if failover occurs for a standard tier instance. To ensure that alerts always fire, we recommend keeping the threshold value to 0"
    mime_type = "text/markdown"
  }

  # Mirrors the JSON userLabels
  user_labels = {
    resource_type = "redis_instance"
    region        = var.region
    instance_id   = var.instance_id
    project_id    = var.project_id
    context       = "redis"
  }

  conditions {
    display_name = "Cloud Memorystore Redis Instance - Node Role"

    condition_threshold {
      # Detects role change by non-zero standard deviation over the 5-min window
      filter = <<-EOT
        resource.type = "redis_instance"
        AND resource.labels.instance_id = "${local.redis_instance_path}"
        AND metric.type = "redis.googleapis.com/replication/role"
      EOT

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_STDDEV"
      }

      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"

      trigger {
        count = 1
      }
    }
  }

  alert_strategy {
    auto_close = "604800s" # 7 days
  }

  notification_channels = var.notification_channel_ids
}
