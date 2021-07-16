
data "ibm_resource_group" "cde" {
  name = var.resource_group
}

data "ibm_is_zones" "mzr" {
  region = var.region
}

data "ibm_is_ssh_key" "region" {
  name = var.ssh_key
}