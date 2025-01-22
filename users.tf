
locals {
  # get the file, if not exist an empty list is returned.
  users = try(yamldecode(file(var.users_file)).users, [])
  # creates a map of users, adding iam_enabled=false if not specified
  users_map = { for user in local.users : user.username => merge(user, { iam_enabled = try(var.iam_enabled, false) }) }

  role_mappings = merge([
    # Outer loop: iterate through each user in users_map
    for username, user in local.users_map : {
      #Inner loop: iterate through each role assigned to this user
      for role in try(user.iam[terraform.workspace].roles, []) : "${username}-${role}" => {
        username = username # assign
        role     = role
      } if var.iam_enabled # Only allow this all to happen if iam is enabled
    }
  ]...) # splat! converts the map to individual arguments for merge()
}

variable "iam_enabled" {
  description = "Whether to enable IAM role assignments"
  type        = bool
  default     = true
}

variable "users_file" {
  description = "Path to users YAML file"
  type        = string
  default     = "./users/users.yaml"
}

# Call the module for submodule related to iam
module "iam" {
  for_each = var.iam_enabled != false ? local.role_mappings : {}

  source = "./modules/iam"

  project_id = local.project_id
  role       = each.value.role
  member     = local.users_map[each.value.username].email
}
