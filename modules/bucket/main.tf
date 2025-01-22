module "storage_bucket" {
  for_each = { for bucket in var.storage_bucket_configs : bucket.name => bucket }

  source     = "terraform-google-modules/cloud-storage/google"
  version    = "~> 3.4"
  prefix     = each.value.prefix
  names      = [each.value.name]
  project_id = var.project_id
  location   = each.value.location
  labels     = each.value.labels
  versioning = {
    (each.value.name) = each.value.versioning
  }

  lifecycle_rules = [
    for rule in each.value.lifecycle_rules : {
      action = {
        type = rule.action
      }
      condition = {
        age = rule.age_days
      }
    }
  ]
}
