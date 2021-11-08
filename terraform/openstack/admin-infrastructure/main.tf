data "template_cloudinit_config" "admin_cloudinit" {
  part {
    content_type = "text/cloud-config"
    content      = templatefile("${abspath(path.module)}/../config/init.yml", {
      host_name = "admin-server"
      auth_key  = file("${abspath(path.module)}/../../keys/org.pub")
      name      = "org"
    })
  }
}

resource "openstack_networking_floatingip_v2" "fip" {
  pool = "public"
}
resource "openstack_compute_floatingip_associate_v2" "fip" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.admin.id
}

resource "openstack_compute_instance_v2" "admin" {
  name        = "admin-vm"
  image_name  = "ubuntu-custom"
  flavor_name = "m1.medium"
  user_data   = data.template_cloudinit_config.admin_cloudinit.rendered

  network {
    port           = openstack_networking_port_v2.port.id
    access_network = true
  }

}
resource "null_resource" "copy" {
  depends_on = [openstack_compute_instance_v2.admin]
  provisioner "file" {
    source      = "../../../admin-node"
    destination = "/home/org/"

    connection {
      type     = "ssh"
      user     = "org"
      private_key = file("${abspath(path.module)}/../../keys/org_key/org")
      host     = openstack_networking_floatingip_v2.fip.address
    }
  }
}
output "ip" {
  value = openstack_networking_floatingip_v2.fip.address
}
