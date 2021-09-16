variable "libvirt_path_pool" {
  type = string
  description = "path for libvirt pool"
  default = "<choose_path>"
}

variable "os_images_path" {
  type = string
  description = "path to images dir"
  default = "<choose_path>"
}

variable "os_images" {
  type = list(string)
  description = "images for VMs"
  default = ["CentOS-8-ec2-8.1.1911-20200113.3.x86_64.qcow2", "ubuntu-16.04-server-cloudimg-amd64-disk1.img", "ubuntu-16.04-server-cloudimg-amd64-disk1.img"]
}

variable "hostnames" {
  type = list(string)
  description = "vm hostname"
  default = ["centos.monitoring", "ubuntu.attack", "ubuntu.defence"]
}

variable "ssh_username" {
  # type = list(string)
  description = "the ssh user to use"
  default     = "user"
  #default    = [""]
}