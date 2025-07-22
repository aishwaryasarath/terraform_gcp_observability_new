variable "name" {
  type        = string
  description = "Redis instance name"
}

variable "region" {
  type        = string
  description = "GCP region for Redis"
}

variable "tier" {
  type        = string
  default     = "STANDARD_HA"
  description = "Redis tier: BASIC or STANDARD_HA"
}

variable "memory_size_gb" {
  type        = number
  description = "Memory size in GB"
}

variable "display_name" {
  type        = string
  default     = null
  description = "Optional display name"
}
variable "read_replicas_mode" {
  type        = string
  default     = "READ_REPLICAS_ENABLED"
  description = "Read replica mode for Redis instance"
}
variable "project" {
  type        = string
  description = "GCP project ID"
  default     = null

}
variable "replica_count" {
  type        = number
  default     = 1
  description = "Number of read replicas for the Redis instance"

}

