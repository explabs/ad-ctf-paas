data "openstack_networking_network_v2" "network" {
  name = "game-network"
}

resource "openstack_networking_secgroup_v2" "secgroup_1" {
  name                 = "secgroup_1"
  description          = "My neutron security group"
  delete_default_rules = true
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

resource "openstack_networking_subnet_route_v2" "subnet_route" {
  count            = length(var.teams)
  subnet_id        = openstack_networking_subnet_v2.subnets.*.id[count.index]
  destination_cidr = "10.0.0.0/24"
  next_hop         = "192.168.100.1"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "10.0.0.0/24"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_1.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_2" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "10.0.0.0/24"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_1.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  port_range_min    = 0
  port_range_max    = 0
  remote_ip_prefix  = "10.0.0.0/24"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_1.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_4" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  port_range_min    = 0
  port_range_max    = 0
  remote_ip_prefix  = "10.0.0.0/24"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_1.id}"
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_5" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "10.0.0.0/24"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_1.id}"
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_6" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "10.0.0.0/24" 
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_1.id}"
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
  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}
