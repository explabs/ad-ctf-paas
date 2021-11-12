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

resource openstack_compute_secgroup_v2 "secgroup" {
  name        = "allow-ssh-and-http"
  description = "Allow ssh and http traffic from everywhere"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
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
  security_group_ids = [openstack_compute_secgroup_v2.secgroup.id]

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnets.*.id[count.index]
    ip_address = var.ips[count.index]
  }
}