# variable "libvirt_path_pool" {
#   description = "path for libvirt pool"
#   default = "${abspath(path.module)}/pool-ubuntu"
# }

variable "hostnames" {
  type = list(string)
  description = "vm hostname"
  default = ["ubuntu.monitoring", "ubuntu.attack", "ubuntu.defence"]
}

variable "ssh_username" {
  description = "the ssh user to use"
  default     = "user"
}