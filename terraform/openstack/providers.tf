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