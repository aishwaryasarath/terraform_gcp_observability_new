variable "name" {}
variable "location" {
  default = "US"
}
variable "project" {
  description = "The GCP project ID where the bucket will be created."
  type        = string

}
variable "storage_class" {
  description = "value of the storage class for the bucket."
  type        = string
  default     = "STANDARD"
}
variable "versioning" {
  type    = bool
  default = true

}
variable "force_destroy" {
  type    = bool
  default = false
}
