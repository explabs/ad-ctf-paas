data "template_cloudinit_config" "users_cloudinit" {
  count = length(var.teams)
  part {
    content_type = "text/cloud-config"
    content = templatefile("${abspath(path.module)}/../config/init.yml", {
      host_name = var.teams[count.index]
      auth_key = file("${abspath(path.module)}/../../keys/${var.teams[count.index]}.pub")
      name = "team"
    })
  }
}

resource "openstack_compute_instance_v2" "users" {
  count       = length(var.teams)
  name        = format("users-vm%d", count.index)
  image_name  = "ubuntu-custom"
  flavor_name = "m1.medium"
#  key_pair    = openstack_compute_keypair_v2.users-keypairs.*.name[count.index]
  user_data = data.template_cloudinit_config.users_cloudinit.*.rendered[count.index]

  network {
    port           = openstack_networking_port_v2.ports.*.id[count.index]
    access_network = true
  }
}
resource "openstack_networking_floatingip_v2" "fip" {
  count = length(var.teams)
  pool  = "public"
}
resource "openstack_compute_floatingip_associate_v2" "fip" {
  count       = length(var.teams)
  floating_ip = openstack_networking_floatingip_v2.fip.*.address[count.index]
  instance_id = openstack_compute_instance_v2.users.*.id[count.index]
}

output "ip" {
  value = openstack_networking_floatingip_v2.fip.*.address
}
