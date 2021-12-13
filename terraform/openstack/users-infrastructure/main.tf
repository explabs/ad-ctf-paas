data "template_cloudinit_config" "users_cloudinit" {
  count = length(var.teams)
  part {
    content_type = "text/cloud-config"
    content = templatefile("${abspath(path.module)}/../config/user_init.yml", {
      host_name = var.teams[count.index]
      auth_key = file("${abspath(path.module)}/../../keys/${var.teams[count.index]}.pub")
      name = "team"
    })
  }
}

resource "openstack_compute_instance_v2" "users" {
  count       = length(var.teams)
  name        = format("users-vm%d", count.index)
  image_name  = var.os_image
  flavor_name = var.flavour_name
#  key_pair    = openstack_compute_keypair_v2.users-keypairs.*.name[count.index]
  user_data = data.template_cloudinit_config.users_cloudinit.*.rendered[count.index]
  security_groups = ["${openstack_networking_secgroup_v2.secgroup.name}"]
  network {
    port           = openstack_networking_port_v2.ports.*.id[count.index]
    access_network = true

  }
}
