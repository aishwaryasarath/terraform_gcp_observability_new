resource "google_logging_metric" "secret_version_added" {
  name = "secret_version_added_test_master_key"
  #project     = var.project_id
  description = "Count of times a new version is added to secret test_master_key"

  # Filter to match your provided JSON example
  filter = <<EOT
resource.type="audited_resource"
resource.labels.service="secretmanager.googleapis.com"
protoPayload.methodName="google.cloud.secretmanager.v1.SecretManagerService.AddSecretVersion"
protoPayload.resourceName:"projects/658025721055/secrets/test_master_key/versions/"
EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    labels {
      key         = "secret_name"
      value_type  = "STRING"
      description = "The name of the secret"
    }

    labels {
      key         = "version"
      value_type  = "STRING"
      description = "The version number of the secret"
    }

  }
  label_extractors = {
    secret_name = "REGEXP_EXTRACT(protoPayload.response.name, \".*/secrets/([^/]+)/versions/\\\\d+$\")"
    version     = "REGEXP_EXTRACT(protoPayload.resourceName, \".*/versions/([0-9]+)$\")"
  }
}

# --------- Alert Policy for Secret Version Add ---------
resource "google_monitoring_alert_policy" "secret_version_added_alert" {
  #project      = var.project_id
  display_name = "Secret Version Added - test_master_key"

  documentation {
    content   = <<EOT
New secret version added: $${metric.label.version}  
Project id: $${resource.labels.project_id}  
Secret name: $${metric.label.secret_name}
EOT
    mime_type = "text/markdown"
  }

  combiner = "OR"

  conditions {
    display_name = "New Secret Version Added Condition"

    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.secret_version_added.name}\" AND resource.type=\"audited_resource\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"

      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.notification_channel_ids
}
