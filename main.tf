module "vpc" {
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Module.git"
  name           = "${var.name}-vpc"
  resource_group = data.ibm_resource_group.cde.id
  tags           = concat(var.tags, ["region:${var.region}", "project:${var.name}"])
}

module "public_gateway" {
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Public-Gateway-Module.git"
  name           = "${var.name}-${data.ibm_is_zones.mzr.zones[0]}-pub-gw"
  zone           = data.ibm_is_zones.mzr.zones[0]
  vpc            = module.vpc.id
  resource_group = data.ibm_resource_group.cde.id
  tags           = concat(var.tags, ["project:${var.name}", "zone:${data.ibm_is_zones.mzr.zones[0]}"])
}

module "subnet" {
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Subnet-Module.git"
  name           = "${var.name}-${data.ibm_is_zones.mzr.zones[0]}-subnet"
  resource_group = data.ibm_resource_group.cde.id
  address_count  = "128"
  vpc            = module.vpc.id
  zone           = data.ibm_is_zones.mzr.zones[0]
  public_gateway = module.public_gateway.id
  tags           = concat(var.tags, ["project:${var.name}", "zone:${data.ibm_is_zones.mzr.zones[0]}"])
}

module "bastion" {
  source            = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Instance-Module.git"
  vpc_id            = module.vpc.id
  subnet_id         = module.subnet.id
  ssh_keys          = [data.ibm_is_ssh_key.region.id]
  resource_group_id = data.ibm_resource_group.cde.id
  name              = "${var.name}-bastion"
  zone              = data.ibm_is_zones.mzr.zones[0]
  allow_ip_spoofing = false
  security_groups   = [module.vpc.default_security_group]
  tags              = concat(var.tags, ["project:${var.name}", "zone:${data.ibm_is_zones.mzr.zones[0]}"])
  user_data         = file("${path.module}/install.yml")
}

resource "ibm_is_floating_ip" "bastion" {
  name           = "${var.name}-bastion-public-ip"
  resource_group = data.ibm_resource_group.cde.id
  target         = module.bastion.primary_network_interface_id
}

module "autoscale-group" {
  source         = "./autoscale"
  name           = var.name
  zone           = data.ibm_is_zones.mzr.zones[0]
  resource_group = data.ibm_resource_group.cde.id
  vpc            = module.vpc.id
  subnet         = module.subnet.id
  ssh_key        = [data.ibm_is_ssh_key.region.id]
}