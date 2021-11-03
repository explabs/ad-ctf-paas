variable "os_image" {
  description = "images for VMs"
  default     = "focal-server-cloudimg-amd64.img"
}
variable "interface" {
  default = "ens01"
}
variable "memory" {
 default = "4096"
}
variable "vcpu" {
  default = 2
}
