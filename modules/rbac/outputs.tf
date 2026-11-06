output "custom_role_definition_id" {
  description = "Resource ID of the Landing Zone Operator custom role."
  value       = azurerm_role_definition.lz_operator.role_definition_resource_id
}

output "role_assignment_ids" {
  description = "Role assignment IDs keyed by assignment name."
  value       = { for key, assignment in azurerm_role_assignment.this : key => assignment.id }
}
