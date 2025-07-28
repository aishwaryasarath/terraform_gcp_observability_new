variable "redis_instance_id" {
  type        = string
  description = "Redis instance ID"
}

variable "redis_instance_name" {
  type        = string
  description = "Redis instance name"

}



variable "environment" {
  type = string
}
variable "project_id" {
  type        = string
  description = "GCP Project ID"
}
# variable "region" {
#   type        = string
#   description = "GCP region for Redis"
# }
