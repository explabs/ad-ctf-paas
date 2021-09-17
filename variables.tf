variable "os_images" {
  type = list(string)
  description = "images for VMs"
  default = ["focal-server-cloudimg-amd64.img", "focal-server-cloudimg-amd64.img", "focal-server-cloudimg-amd64.img"]
}

variable "hostnames" {
  type = list(string)
  description = "vm hostname"
  default = ["monitoring", "attack", "defence"]
}

variable "ssh_username" {
  # type = list(string)
  description = "the ssh user to use"
  default     = "user"
  #default    = [""]
}