variable "instance_name" {}
variable "machine_type" {}
variable "zone" {}
variable "image" {}
variable "tags" {
  type    = list(string)
  default = []
}
