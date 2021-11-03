resource "openstack_compute_instance_v2" "test" {
  name            = "test-vm"
  image_name      = "cirros-0.5.2-x86_64-disk"
  flavor_name     = "m1.tiny"
  key_pair        = "demo"

  network {
    name = "private"
    access_network = true
  }
}
resource "openstack_networking_floatingip_v2" "fip_1" {
  pool = "public"
}
resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = openstack_networking_floatingip_v2.fip_1.address
  instance_id = openstack_compute_instance_v2.test.id
}
output "ip" {
  value = openstack_networking_floatingip_v2.fip_1.address
}
#openstack server create --nic net-id=b5d27bec-5627-450d-939d-cc319ab92527 --flavor 1 --image e0718133-3b7b-4677-bb21-95188b770716 --key-name test test1