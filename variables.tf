variable "os_images" {
  description = "images for VMs"
  default     = [
    "focal-server-cloudimg-amd64.img",
    "focal-server-cloudimg-amd64.img",
    "focal-server-cloudimg-amd64.img",
  ]
}
variable "interface" {
  default = "ens01"
}
variable "memory" {
  default = "2048"
}
variable "vcpu" {
  default = 2
}

variable "macs" {
  default = [
    "52:54:00:50:99:c5",
    "52:54:00:0e:87:be",
    "52:54:00:9d:90:38",
  ]
}