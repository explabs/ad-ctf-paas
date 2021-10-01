variable "teams" {
  default = ["naliway", "nakateam"]
}
variable "ips" {
  default = ["10.0.1.10", "10.0.2.10"]
}
variable "network_name" {
  default = ["virtbr-team1", "virtbr-team2"]
}
variable "gateways" {
  default = ["10.0.1.254", "10.0.2.254"]
}
variable "macs" {
  default = [
    "52:54:00:50:99:c5",
    "52:54:00:0e:87:be",
    "52:54:00:9d:90:38",
  ]
}
