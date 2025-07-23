variable "project_id" {
  type        = string
  description = "GCP Project ID"

}
variable "notification_channel_ids" {
  type        = list(string)
  description = "List of notification channel IDs for alerting"

}
variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, prod)"

}
