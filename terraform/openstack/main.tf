resource "openstack_compute_instance_v2" "test" {
  count = length(var.teams)
  name            = format("vm%d", count.index)
  image_name      = "cirros-0.5.2-x86_64-disk"
  flavor_name     = "m1.tiny"
  key_pair        = "demo"
  user_data = templatefile("${path.module}/../config/init.yml", {
    host_name = var.teams[count.index]
    auth_key = file("${abspath(path.module)}/../keys/${var.teams[count.index]}.pub")
    admin_key = file("${abspath(path.module)}/../keys/org.pub")
    name = var.teams[count.index]
  })


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
#openstack server create --nic net-id=b5d27bec-5627-450d-939d-cc319ab92527 --flavor 1 --image e0718133-3b7b-4677-bb21-95188b770716 --key-name test test1
