data "openstack_networking_network_v2" "network" {
  name = "game-network"
}

resource "openstack_networking_subnet_v2" "subnets" {
  count      = length(var.teams)
  network_id = data.openstack_networking_network_v2.network.id
  cidr       = var.cidr[count.index]
  ip_version = 4
}

data "openstack_networking_router_v2" "router" {
  name = "game-router"
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  count     = length(var.teams)
  router_id = data.openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnets.*.id[count.index]
}

data openstack_networking_secgroup_v2 "secgroup"{
  name = "all-open"
}


resource "openstack_networking_subnet_route_v2" "subnet_route" {
  count            = length(var.teams)
  subnet_id        = openstack_networking_subnet_v2.subnets.*.id[count.index]
  destination_cidr = "10.0.0.0/24"
  next_hop         = openstack_networking_subnet_v2.subnets.*.gateway_ip[count.index]
}

resource "openstack_networking_port_v2" "ports" {
  count          = length(var.teams)
  name           = format("port-%d", count.index)
  network_id     = data.openstack_networking_network_v2.network.id
  admin_state_up = "true"
  security_group_ids = [data.openstack_networking_secgroup_v2.secgroup.id]

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnets.*.id[count.index]
    ip_address = var.ips[count.index]
  }
}

#resource "openstack_networking_port_v2" "subports" {
#  count          = length(var.teams)
#  depends_on = [
#    openstack_networking_subnet_v2.subnets,
#  ]
#
#  name           = format("subport-%d", count.index)
#  network_id     = data.openstack_networking_network_v2.network.id
#  admin_state_up = "true"
#}
#
#resource "openstack_networking_trunk_v2" "trunk_1" {
#
#  count          = length(var.teams)
#  name           = format("trunk-%d", count.index)
#  admin_state_up = "true"
#  port_id        = openstack_networking_port_v2.ports.*.id[count.index]
#
#  sub_port {
#    port_id           = openstack_networking_port_v2.subports.*.id[count.index]
#    segmentation_id   = count.index + 2
#    segmentation_type = "vlan"
#  }
#}