resource "ibm_is_instance_template" "lunchlab" {
  name           = "${var.name}-instance-template"
  resource_group = var.resource_group

  image   = data.ibm_is_image.default.id
  profile = var.default_instance_profile

  primary_network_interface {
    subnet            = var.subnet
    allow_ip_spoofing = false
  }

  vpc  = var.vpc
  zone = var.zone
  keys = var.ssh_key

  boot_volume {
    name                             = "${var.name}-instance-boot-vol"
    delete_volume_on_instance_delete = true
  }
  user_data = file("${path.module}/install.yml")
}

resource "ibm_is_instance_group" "lunchlab" {
  name              = "${var.name}-instance-group"
  resource_group    = var.resource_group
  instance_template = ibm_is_instance_template.lunchlab.id
  instance_count    = 1
  subnets           = [var.subnet]
  timeouts {
    create = "90m"
    delete = "30m"
    update = "15m"
  }
}

resource "ibm_is_instance_group_manager" "lunchlab" {
  name                 = "${var.name}-group-manager"
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
  name                   = "${var.name}-network-policy"
}