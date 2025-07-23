variable "alert_email" {
  type        = string
  description = "Email address to send alert notifications"
}
variable "project" {
  type        = string
  description = "GCP project ID"
  default     = null

}
