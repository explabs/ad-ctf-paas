resource "openstack_compute_keypair_v2" "users-keypairs" {
  count = length(var.teams)
  name       = format("%s-keypair", var.teams[count.index])
  public_key = file("${abspath(path.module)}/../keys/${var.teams[count.index]}.pub")
}

resource "openstack_compute_instance_v2" "test" {
  count = length(var.teams)
  name            = format("vm%d", count.index)
  image_name      = "ubuntu-custom"
  flavor_name     = "m1.medium"
  key_pair = openstack_compute_keypair_v2.users-keypairs.*.name[count.index]

  network {
    name = "private"
    access_network = true
  }
}
resource "openstack_networking_floatingip_v2" "fip" {
  count = length(var.teams)
  pool = "public"
}
resource "openstack_compute_floatingip_associate_v2" "fip" {
  count = length(var.teams)
  floating_ip = openstack_networking_floatingip_v2.fip.*.address[count.index]
  instance_id = openstack_compute_instance_v2.test.*.id[count.index]
}

output "ip" {
  value = openstack_networking_floatingip_v2.fip.*.address
}
