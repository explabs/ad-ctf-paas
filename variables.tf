variable "os_images" {
  type = list(string)
  description = "images for VMs"
  default = [
    "focal-server-cloudimg-amd64.img",
    "focal-server-cloudimg-amd64.img",
    "focal-server-cloudimg-amd64.img",
  ]
}
variable "hosts" {
  type = number
  default = 3
}
variable "interface" {
  type = string
  default = "ens01"
}
variable "memory" {
  type = string
  default = "2048"
}
variable "vcpu" {
  type = number
  default = 2
}

variable "hostnames" {
  type = list(string)
  description = "vm hostname"
  default = [
    "monitoring",
    "attack",
    "defence",
  ]
}

variable "ssh_username" {
  type = list(string)
  description = "the ssh user to use"
  default = ["soc", "red", "blue"]
}

variable "ssh_keys" {
  type = list(string)
  default = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC87GI7G0JKRh86m0h0FlUz8GjvtpnMx6zUw6rM4S/r0ueHvTvn6Uy/jV4SkqVuXi1a3LFVlnoYtBw4/CN3CgwAUUCTscSImhX8N06mrNUStcKnyCMXJDdEFuDwcYo/rndOLUeh1a8eiCJtoSvlLuoLRpQew3bpDu7tgIOYQUl9WUZkwsppq6OXlPtUeqQ4W9PnQPXSggYt9bVTd6BCJeeOaPHezJI7cKvyVl5P7qH64dvzLE7wG1rix43k8V8X3Lld8t60B2T7Fx2Q6j4wiV72knVVx83qdFZDX0Tqkb8SONUkNlQYlGRj191Hhvuvb1CKmzpM0RslhWTQEqR+GMW62BUq1UhJd75l/5qrCoyrJEZIv8y+QFiWGfDSTWGfv7XR+NTxUysHr18Qi1B7Ds1ntz8fUVIZAXKsjx/Jqq7iaDdGehf1qgBgwEQaMHjBfdBB8BZM/2QeC2OAbt15jQyZM5H/zjBAumr3SbGgBbkpTzqUV8sQJYw1XhtkswC3+mU=",
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC87GI7G0JKRh86m0h0FlUz8GjvtpnMx6zUw6rM4S/r0ueHvTvn6Uy/jV4SkqVuXi1a3LFVlnoYtBw4/CN3CgwAUUCTscSImhX8N06mrNUStcKnyCMXJDdEFuDwcYo/rndOLUeh1a8eiCJtoSvlLuoLRpQew3bpDu7tgIOYQUl9WUZkwsppq6OXlPtUeqQ4W9PnQPXSggYt9bVTd6BCJeeOaPHezJI7cKvyVl5P7qH64dvzLE7wG1rix43k8V8X3Lld8t60B2T7Fx2Q6j4wiV72knVVx83qdFZDX0Tqkb8SONUkNlQYlGRj191Hhvuvb1CKmzpM0RslhWTQEqR+GMW62BUq1UhJd75l/5qrCoyrJEZIv8y+QFiWGfDSTWGfv7XR+NTxUysHr18Qi1B7Ds1ntz8fUVIZAXKsjx/Jqq7iaDdGehf1qgBgwEQaMHjBfdBB8BZM/2QeC2OAbt15jQyZM5H/zjBAumr3SbGgBbkpTzqUV8sQJYw1XhtkswC3+mU=",
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC87GI7G0JKRh86m0h0FlUz8GjvtpnMx6zUw6rM4S/r0ueHvTvn6Uy/jV4SkqVuXi1a3LFVlnoYtBw4/CN3CgwAUUCTscSImhX8N06mrNUStcKnyCMXJDdEFuDwcYo/rndOLUeh1a8eiCJtoSvlLuoLRpQew3bpDu7tgIOYQUl9WUZkwsppq6OXlPtUeqQ4W9PnQPXSggYt9bVTd6BCJeeOaPHezJI7cKvyVl5P7qH64dvzLE7wG1rix43k8V8X3Lld8t60B2T7Fx2Q6j4wiV72knVVx83qdFZDX0Tqkb8SONUkNlQYlGRj191Hhvuvb1CKmzpM0RslhWTQEqR+GMW62BUq1UhJd75l/5qrCoyrJEZIv8y+QFiWGfDSTWGfv7XR+NTxUysHr18Qi1B7Ds1ntz8fUVIZAXKsjx/Jqq7iaDdGehf1qgBgwEQaMHjBfdBB8BZM/2QeC2OAbt15jQyZM5H/zjBAumr3SbGgBbkpTzqUV8sQJYw1XhtkswC3+mU=",
  ]
}

variable "ips" {
  type = list(string)
  default = [
    "192.168.122.11",
    "192.168.122.22",
    "192.168.122.33",
  ]
}
variable "macs" {
  type = list(string)
  default = [
    "52:54:00:50:99:c5",
    "52:54:00:0e:87:be",
    "52:54:00:9d:90:38",
  ]
}