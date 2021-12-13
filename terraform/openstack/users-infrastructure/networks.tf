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

resource "openstack_networking_secgroup_v2" "secgroup" {
  name                  = "secgroup_1"
  description           = "My neutron security group"
  delete_default_rules  = true
}


resource "openstack_networking_secgroup_rule_v2" "rule_ingress_all-tcp-v4" {
  direction = "ingress"
  ethertype = "IPv4"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup.id}"
  depends_on = [openstack_networking_secgroup_v2.secgroup]
}

resource "openstack_networking_secgroup_rule_v2" "rule_egress_all-tcp-v4" {
  direction = "egress"
  ethertype = "IPv4"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup.id}"
  depends_on = [openstack_networking_secgroup_v2.secgroup]
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

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnets.*.id[count.index]
    ip_address = var.ips[count.index]
  }
}

resource "openstack_networking_port_secgroup_associate_v2" "port" {
  count              = length(var.teams)
  port_id            = "${openstack_networking_port_v2.ports.*.id[count.index]}"
  enforce            = "true"
  security_group_ids = [
    "${openstack_networking_secgroup_v2.secgroup.id}"
  ]

}
