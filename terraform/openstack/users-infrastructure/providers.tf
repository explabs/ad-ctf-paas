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
  # Your user account.
  user_name        = var.user_name
  # The password of the account
  password         = var.password
  # The tenant token can be taken from the project Settings tab - > API keys.
  # Project ID will be our token.
  tenant_id        = var.tenant_id
  # The indicator of the location of users.
  user_domain_name = var.user_domain_name
  # API endpoint
  # Terraform will use this address to access the VK Cloud Solutions api.
  auth_url         = var.auth_url
  # use octavia to manage load balancers
  use_octavia      = true
  # Region name
  region           = "RegionOne"
}