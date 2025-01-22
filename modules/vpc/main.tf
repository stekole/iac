module "vpc" {
  for_each = { for network in var.network_configs : network.name => network }
  source   = "terraform-google-modules/network/google"
  version  = "~> 5.0"

  project_id   = var.project_id
  network_name = each.value.name
  routing_mode = "GLOBAL"

  subnets = [
    for subnet in each.value.subnets : {
      subnet_name           = subnet.name
      subnet_ip             = subnet.cidr
      subnet_region         = each.value.region
      subnet_private_access = subnet.private
    }
  ]
}

variable "project_id" {
  type = string
}

variable "network_configs" {}