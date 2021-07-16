variable "default_instance_profile" {
  type    = string
  default = "cx2-2x4"
}

variable "os_image" {
  type        = string
  description = "OS Image to use for VPC instances. Default is currently Ubuntu 20."
  default     = "ibm-ubuntu-20-04-minimal-amd64-2"
}

variable "name" {}
variable "vpc" {}
variable "zone" {}
variable "ssh_key" {}
variable "subnet" {}
variable "resource_group" {}