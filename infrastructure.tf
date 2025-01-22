locals {
  # coalesce returns the first one that isn't null or an empty string.
  infrastructure_file = coalesce(var.infrastructure_file, "./infrastructure/${terraform.workspace}/infrastructure.yaml")

  infra = try(yamldecode(file(local.infrastructure_file)).infrastructure, {})

  # Flatten compute instance configurations 
  compute_instance_configs = flatten([
    for instance in try(local.infra.compute_instances, []) : {
      name            = instance.name
      machine_type    = instance.machine_type
      zone            = instance.zone
      subnet          = instance.subnet
      network         = instance.network
      tags            = instance.tags
      service_account = instance.service_account
      labels          = instance.labels
    }
  ])

  # Flatten storage bucket configurations
  storage_bucket_configs = flatten([
    for bucket in try(local.infra.storage_buckets, []) : {
      name            = bucket.name
      location        = bucket.location 
      versioning      = bucket.versioning
      lifecycle_rules = bucket.lifecycle_rules
      labels          = bucket.labels
      prefix          = bucket.prefix
    }
  ])
}

variable "infrastructure_file" {
  description = "Path to infrastructure YAML file"
  type        = string
  default     = null
}

module "storage_bucket" {
  for_each               = { for bucket in try(local.infra.storage_buckets, []) : bucket.name => bucket }
  source                 = "./modules/bucket"
  storage_bucket_configs = [each.value] # Pass as single-element list
  project_id             = local.project_id
}

module "vpc" {
  for_each        = { for network in try(local.infra.networks, []) : network.name => network }
  source          = "./modules/vpc"
  network_configs = [each.value]
  project_id      = local.project_id
}
