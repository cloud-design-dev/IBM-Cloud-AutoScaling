resource "ibm_is_instance_template" "lunchlab" {
  name = "lunchlab-instance-template"

  image   = data.ibm_is_image.default.id
  profile = var.default_instance_profile

  primary_network_interface {
    subnet            = data.ibm_is_subnet.zone2.id
    allow_ip_spoofing = false
  }

  vpc  = data.ibm_is_vpc.devland.id
  zone = data.ibm_is_zones.mzr.zones[1]
  keys = [data.ibm_is_ssh_key.hyperion.id]

  boot_volume {
    name                             = "lunchlab-instance-boot-vol"
    delete_volume_on_instance_delete = true
  }
  user_data = file("${path.module}/install.yml")
}

resource "ibm_is_instance_group" "lunchlab" {
  name              = "lunchlab-instance-group"
  resource_group    = data.ibm_resource_group.cde.id
  instance_template = ibm_is_instance_template.lunchlab.id
  instance_count    = 1
  subnets           = [data.ibm_is_subnet.zone2.id]
  timeouts {
    create = "90m"
    delete = "30m"
    update = "15m"
  }
}


resource "ibm_is_instance_group_manager" "lunchlab" {
  name                 = "lunchlab-group"
  aggregation_window   = 120
  instance_group       = ibm_is_instance_group.lunchlab.id
  cooldown             = 300
  manager_type         = "autoscale"
  enable_manager       = true
  max_membership_count = 4
  min_membership_count = 1
}


resource "ibm_is_instance_group_manager_policy" "network" {
  instance_group         = ibm_is_instance_group.lunchlab.id
  instance_group_manager = ibm_is_instance_group_manager.lunchlab.manager_id
  metric_type            = "network_in"
  metric_value           = 5
  policy_type            = "target"
  name                   = "lunchlab-network-policy"
}