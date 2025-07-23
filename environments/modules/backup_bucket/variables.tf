variable "name" {
  type        = string
  description = "Name of the backup bucket"

}
variable "location" {
  type        = string
  description = "Location for the backup bucket"


}
variable "storage_class" {
  type        = string
  description = "Storage class for the backup bucket"
  default     = "STANDARD"

}
variable "labels" {
  description = "values to assign to labels"
  type        = map(string)
  default     = {}
}
variable "versioning" {
  type        = bool
  description = "Enable versioning for the backup bucket"
  default     = true

}
variable "force_destroy" {
  type        = bool
  description = "Allow deletion of non-empty buckets"
  default     = false

}
variable "project" {
  type        = string
  description = "GCP Project ID"


}
