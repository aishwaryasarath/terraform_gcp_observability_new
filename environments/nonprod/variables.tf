# variable "project" {}
# variable "storage_class" {
#   type = string
# }
# variable "versioning" {
#   type = bool

# }
# variable "force_destroy" {
#   type    = bool
#   default = false

# }

variable "regions" {
  type = map(object({
    region       = string
    region_alias = string
  }))

}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}
