
variable "bucket_name" {
  type = string
}

variable "notification_channel_ids" {
  type = list(string)
}
variable "project" {
  type        = string
  description = "GCP Project ID"

}
variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, prod)"

}
