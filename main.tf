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
  path = var.libvirt_path_pool
}

# We fetch the latest ubuntu release image from their mirrors
resource "libvirt_volume" "os-qcow2" {
  count = length(var.hostnames)
  name = "${var.hostnames[count.index]}-qcow2"
  pool = libvirt_pool.os_pools.name
  source = format("${var.os_images_path}%s", var.os_images[count.index])
  format = "qcow2"
}

data "template_file" "user_data" {
  count = length(var.hostnames)
  template = file("${path.module}/config/init.yml")
}


# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "commoninit" {
  count = length(var.hostnames)
  name = "${var.hostnames[count.index]}-commoninit.iso"
  user_data = data.template_file.user_data[count.index].rendered
  pool = libvirt_pool.os_pools.name
}

resource "libvirt_network" "local-kvm" {
  name = "local-kvmnet"
  mode = "nat"
  domain = "local-kvm"
  addresses = ["10.10.10.0/28"]
  dhcp {
    enabled = true
  }
}

# Create the machine
resource "libvirt_domain" "os-domain" {
  count = length(var.hostnames)
  name = "${var.hostnames[count.index]}"
  memory = "2048"
  vcpu = 1
  qemu_agent = true
  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  network_interface {
    network_id = "${libvirt_network.local-kvm.id}"
    wait_for_lease = true
   
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
#   provisioner "remote-exec" {
#     inline = [
#       "echo hello"
#     ]

#     connection {
#       type        = "ssh"
#       user        = var.ssh_username
#       host        = libvirt_domain.os-domain[0].network_interface[0].addresses[0]
#       private_key = file("${path.module}/user_rsa")
#     }   
#   }
#   provisioner "local-exec" {
#       command = "ansible-playbook -u ${var.ssh_username} --private-key /home/fral/projects/ad-infrastructure/user_rsa /home/fral/projects/ad-infrastructure/ansible/playbook.yml"
#   }

}

# IPs: use wait_for_lease true or after creation use terraform refresh and terraform show for the ips of domain
output "hostnames" {
  value = "${libvirt_domain.os-domain.*}"
}