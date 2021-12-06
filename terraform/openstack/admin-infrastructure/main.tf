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
  pool = data.openstack_networking_network_v2.network.name
}

resource "openstack_compute_floatingip_associate_v2" "fip" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.admin.id
}

data "openstack_images_image_v2" "image" {
  name = var.os_image
}

resource "openstack_compute_instance_v2" "admin" {
  name        = "admin-vm"
  image_name  = data.openstack_images_image_v2.image.name
  flavor_name = var.flavour_name
  user_data   = data.template_cloudinit_config.admin_cloudinit.rendered

  network {
    port           = openstack_networking_port_v2.port.id
    access_network = true
  }
  block_device {
    //id образа "Ubuntu-18.04-Standard"
    uuid                  = data.openstack_images_image_v2.image.id
    source_type           = "image"
    volume_size           = 10
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
}
resource "null_resource" "tasks" {
  depends_on = [openstack_compute_instance_v2.admin]
  provisioner "file" {
    source      = "../../../admin-node/tasks"
    destination = "/home/org/"

    connection {
      type        = "ssh"
      user        = "org"
      private_key = file("${abspath(path.module)}/../../keys/org_key/org")
      host        = openstack_networking_floatingip_v2.fip.address
    }
  }
}
resource "null_resource" "configs" {
  depends_on = [openstack_compute_instance_v2.admin]
  provisioner "file" {
    source      = "../../../admin-node/configs"
    destination = "/home/org/"

    connection {
      type        = "ssh"
      user        = "org"
      private_key = file("${abspath(path.module)}/../../keys/org_key/org")
      host        = openstack_networking_floatingip_v2.fip.address
    }
  }
}
resource "null_resource" "compose" {
  depends_on = [openstack_compute_instance_v2.admin]
  provisioner "file" {
    source      = "../../../admin-node/docker-compose.yml"
    destination = "/home/org/docker-compose.yml"

    connection {
      type        = "ssh"
      user        = "org"
      private_key = file("${abspath(path.module)}/../../keys/org_key/org")
      host        = openstack_networking_floatingip_v2.fip.address
    }
  }
}
output "ip" {
  value = openstack_networking_floatingip_v2.fip.address
}
