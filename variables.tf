variable "region" {
  type        = string
  description = "The region where the VPC resources will be deployed."
  default     = "us-south"
}

variable "ssh_key" {
  type        = string
  description = "The SSH Key that will be added to the compute instances in the region."
  default     = "hyperion-us-south"
}

variable "default_instance_profile" {
  type    = string
  default = "cx2-2x4"
}

variable "os_image" {
  type        = string
  description = "OS Image to use for VPC instances. Default is currently Ubuntu 20."
  default     = "ibm-ubuntu-20-04-minimal-amd64-2"
}

variable "resource_group" {
  type        = string
  description = "Resource group where resources will be deployed."
  default     = "CDE"
}
