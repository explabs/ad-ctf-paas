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

data "openstack_images_image_v2" "image" {
  name = var.os_image
}

resource "openstack_compute_instance_v2" "users" {
  count       = length(var.teams)
  name        = format("users-vm%d", count.index)
  image_name  = var.os_image
  flavor_name = var.flavour_name
  user_data = data.template_cloudinit_config.users_cloudinit.*.rendered[count.index]
  network {
    port           = openstack_networking_port_v2.ports.*.id[count.index]
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
