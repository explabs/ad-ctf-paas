resource "openstack_networking_network_v2" "network" {
  name           = "game-network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnets" {
  name       = "admin-subnet"
  network_id = openstack_networking_network_v2.network.id
  cidr       = "10.0.0.0/24"
  ip_version = 4
}

resource "openstack_networking_router_v2" "router" {
  name                = "game-router"
  external_network_id = "217fd86d-3c23-4867-9179-22fd23c454c8"
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnets.id
}

data openstack_networking_secgroup_v2 "secgroup"{
  name = "all-open"
}

resource "openstack_networking_port_v2" "port" {
  name           = "admin-port"
  network_id     = openstack_networking_network_v2.network.id
  admin_state_up = "true"
  security_group_ids = [data.openstack_networking_secgroup_v2.secgroup.id]

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnets.id
    ip_address = "10.0.0.10"
  }
}

#resource "openstack_networking_port_v2" "subport" {
#  depends_on = [
#    openstack_networking_subnet_v2.subnets,
#  ]
#
#  name           = "admin-subport"
#  network_id     = openstack_networking_network_v2.network.id
#  admin_state_up = "true"
#}
#
#resource "openstack_networking_trunk_v2" "trunk_1" {
#  name           = "admin-trunk"
#  admin_state_up = "true"
#  port_id        = openstack_networking_port_v2.port.id
#
#  sub_port {
#    port_id           = openstack_networking_port_v2.subport.id
#    segmentation_id   = 1
#    segmentation_type = "vlan"
#  }
#}