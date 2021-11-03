terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.33.0"
    }
  }
}

provider "openstack" {
  user_name = "demo"
  password = "password"
  user_domain_id = "default"
  auth_url = "http://192.168.100.105/identity"
  region = "RegionOne"
  tenant_name = "demo"
}

resource "openstack_blockstorage_volume_v2" "my_volume" {
  name = "my_volume"
  size = 3
}

resource "openstack_networking_port_v2" "port_1" {
  name           = "port_1"
  network_id     = "${openstack_networking_network_v2.network_1.id}"
  admin_state_up = "true"
}

resource "openstack_compute_keypair_v2" "test-keypair" {
  name       = "my-keypair"
}

resource "openstack_networking_network_v2" "network_1" {
  name           = "network_1"
  admin_state_up = "true"
}

resource "openstack_compute_instance_v2" "my_instance" {
    name      = "my_instance"
    region    = "RegionOne"
    image_id  = "e0718133-3b7b-4677-bb21-95188b770716"
    flavor_id = "42"
    key_pair  = "${openstack_compute_keypair_v2.test-keypair.name}"
    security_groups = ["default"]

  network {
    name = "public"
  }
  
}
resource "openstack_compute_volume_attach_v2" "attached" {
  instance_id = "${openstack_compute_instance_v2.my_instance.id}"
  volume_id   = "${openstack_blockstorage_volume_v2.my_volume.id}"
}

resource "openstack_compute_interface_attach_v2" "ai_1" {
  instance_id = "${openstack_compute_instance_v2.my_instance.id}"
  network_id  = "${openstack_networking_port_v2.port_1.id}"
}