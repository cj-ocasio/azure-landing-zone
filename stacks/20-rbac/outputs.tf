output "custom_role_definition_id" {
  description = "Resource ID of the Landing Zone Operator custom role."
  value       = module.rbac.custom_role_definition_id
}

output "role_assignment_ids" {
  description = "Role assignment IDs keyed by assignment name."
  value       = module.rbac.role_assignment_ids
}
