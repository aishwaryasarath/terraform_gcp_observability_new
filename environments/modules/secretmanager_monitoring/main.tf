

resource "google_logging_metric" "secret_critical_errors" {
  for_each = {
    secret_manager_cancelled_499           = "resource.type=\"audited_resource\" AND resource.labels.service=\"secretmanager.googleapis.com\" AND protoPayload.status.code=1"
    secret_manager_unknown_500             = "resource.type=\"audited_resource\" AND resource.labels.service=\"secretmanager.googleapis.com\" AND protoPayload.status.code=2"
    secret_manager_invalid_argument_400    = "resource.type=\"audited_resource\" AND resource.labels.service=\"secretmanager.googleapis.com\" AND protoPayload.status.code=3"
    secret_manager_deadline_exceeded_504   = "resource.type=\"audited_resource\" AND resource.labels.service=\"secretmanager.googleapis.com\" AND protoPayload.status.code=4"
    secret_manager_not_found_404           = "resource.type=\"audited_resource\" AND resource.labels.service=\"secretmanager.googleapis.com\" AND protoPayload.status.code=5"
    secret_manager_already_exists_409      = "resource.type=\"audited_resource\" AND resource.labels.service=\"secretmanager.googleapis.com\" AND protoPayload.status.code=6"
    secret_manager_permission_denied_403   = "resource.type=\"audited_resource\" AND resource.labels.service=\"secretmanager.googleapis.com\" AND protoPayload.status.code=7"
    secret_manager_resource_exhausted_429  = "resource.type=\"audited_resource\" AND resource.labels.service=\"secretmanager.googleapis.com\" AND protoPayload.status.code=8"
    secret_manager_failed_precondition_400 = "resource.type=\"audited_resource\" AND resource.labels.service=\"secretmanager.googleapis.com\" AND protoPayload.status.code=9"
    secret_manager_aborted_409             = "resource.type=\"audited_resource\" AND resource.labels.service=\"secretmanager.googleapis.com\" AND protoPayload.status.code=10"
    secret_manager_out_of_range_400        = "resource.type=\"audited_resource\" AND resource.labels.service=\"secretmanager.googleapis.com\" AND protoPayload.status.code=11"
    secret_manager_unimplemented_501       = "resource.type=\"audited_resource\" AND resource.labels.service=\"secretmanager.googleapis.com\" AND protoPayload.status.code=12"
    secret_manager_internal_error_500      = "resource.type=\"audited_resource\" AND resource.labels.service=\"secretmanager.googleapis.com\" AND protoPayload.status.code=13"
    secret_manager_unavailable_503         = "resource.type=\"audited_resource\" AND resource.labels.service=\"secretmanager.googleapis.com\" AND protoPayload.status.code=14"
    secret_manager_data_loss_500           = "resource.type=\"audited_resource\" AND resource.labels.service=\"secretmanager.googleapis.com\" AND protoPayload.status.code=15"
    secret_manager_unauthenticated_401     = "resource.type=\"audited_resource\" AND resource.labels.service=\"secretmanager.googleapis.com\" AND protoPayload.status.code=16"
  }

  name        = each.key
  description = "Log-based metric for ${each.key} in Secret Manager"
  filter      = each.value

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }

}



resource "google_monitoring_alert_policy" "secret_error_alerts" {
  for_each = {
    secret_manager_cancelled_499           = "logging.googleapis.com/user/secret_manager_cancelled_499"
    secret_manager_unknown_500             = "logging.googleapis.com/user/secret_manager_unknown_500"
    secret_manager_invalid_argument_400    = "logging.googleapis.com/user/secret_manager_invalid_argument_400"
    secret_manager_deadline_exceeded_504   = "logging.googleapis.com/user/secret_manager_deadline_exceeded_504"
    secret_manager_not_found_404           = "logging.googleapis.com/user/secret_manager_not_found_404"
    secret_manager_already_exists_409      = "logging.googleapis.com/user/secret_manager_already_exists_409"
    secret_manager_permission_denied_403   = "logging.googleapis.com/user/secret_manager_permission_denied_403"
    secret_manager_resource_exhausted_429  = "logging.googleapis.com/user/secret_manager_resource_exhausted_429"
    secret_manager_failed_precondition_400 = "logging.googleapis.com/user/secret_manager_failed_precondition_400"
    secret_manager_aborted_409             = "logging.googleapis.com/user/secret_manager_aborted_409"
    secret_manager_out_of_range_400        = "logging.googleapis.com/user/secret_manager_out_of_range_400"
    secret_manager_unimplemented_501       = "logging.googleapis.com/user/secret_manager_unimplemented_501"
    secret_manager_internal_error_500      = "logging.googleapis.com/user/secret_manager_internal_error_500"
    secret_manager_unavailable_503         = "logging.googleapis.com/user/secret_manager_unavailable_503"
    secret_manager_data_loss_500           = "logging.googleapis.com/user/secret_manager_data_loss_500"
    secret_manager_unauthenticated_401     = "logging.googleapis.com/user/secret_manager_unauthenticated_401"
  }
  depends_on = [
    google_logging_metric.secret_critical_errors
  ]
  display_name = "Secret Manager - ${each.key} Alert"
  combiner     = "OR"

  conditions {
    display_name = "${each.key} errors"
    condition_threshold {
      filter          = "resource.type=\"audited_resource\" AND metric.type=\"${each.value}\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 1
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
}
