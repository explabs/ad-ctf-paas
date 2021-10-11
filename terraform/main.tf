terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.11"
    }
  }
}

# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "os_pools" {
  name = "vm"
  type = "dir"
  path = "${abspath(path.module)}/data/"
}

# We fetch the latest ubuntu release image from their mirrors
resource "libvirt_volume" "os-qcow2" {
  count = length(var.teams)
  name = "${var.teams[count.index]}-qcow2"
  pool = libvirt_pool.os_pools.name
  source = "${abspath(path.module)}/${var.os_image}"
  format = "qcow2"
}


# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "commoninit" {
  count = length(var.teams)
  name = "${var.teams[count.index]}-commoninit.iso"
  pool = libvirt_pool.os_pools.name
  user_data = templatefile("${path.module}/config/init.yml", {
    host_name = var.teams[count.index]
    auth_key = file("${abspath(path.module)}/keys/${var.teams[count.index]}.pub")
    name = var.teams[count.index]
  })
  network_config = templatefile("${path.module}/config/network_config.yml", {
    interface = var.interface
    gateway = var.gateways[count.index]
    ip_addr = var.ips[count.index]
    mac_addr = var.macs[count.index]
  })
}

# Create the machine
resource "libvirt_domain" "os-domain" {
  count = length(var.teams)
  name = var.teams[count.index]
  memory = var.memory
  vcpu = var.vcpu
  qemu_agent = true
  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  network_interface {
    network_name = var.network_name[count.index]
    addresses = [
      var.ips[count.index]
    ]

    mac = var.macs[count.index]
  }


  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = element(libvirt_volume.os-qcow2.*.id, count.index)
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }

  provisioner "remote-exec" {
    inline = ["sudo apt install python3"]
    connection {
      type        = "ssh"
      host        = var.ips[count.index]
      user        = var.teams[count.index]
      private_key = file("${abspath(path.module)}/keys/${var.teams[count.index]}.pub")
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.teams[count.index]} -i '${var.ips[count.index]},' --private-key ${file("${abspath(path.module)}/keys/${var.teams[count.index]}.pub")} vm_packages_installation.yml"
  }
}
