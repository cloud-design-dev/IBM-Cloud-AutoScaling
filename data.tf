
data "ibm_resource_group" "cde" {
  name = var.resource_group
}

data "ibm_is_zones" "mzr" {
  region = var.region
}

data "ibm_is_ssh_key" "hyperion" {
  name = var.ssh_key
}

data "ibm_is_image" "default" {
  name = var.os_image
}

data "ibm_is_subnet" "zone2" {
  name = "zone2-devland"
}

data "ibm_is_vpc" "devland" {
  name = "devland"
}