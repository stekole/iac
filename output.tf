# output "file_content" {
#   value = {
#     for k, v in module.service : k => v.file_content
#   }
# }
# output "file_content" {
#   value = module.create["specific-namespace"].file_content
# }

output "project_id" {
  value = local.project_id
}

output "regions" {
  value = try(local.regions[local.env], local.regions["default"])
}

output "environment" {
  value = local.env
}
