output "tenant_id" {
  description = "Tenant that hosts the landing zone."
  value       = data.azurerm_client_config.current.tenant_id
}

output "prefix" {
  description = "Naming prefix shared by every stack."
  value       = var.prefix
}

output "location" {
  description = "Primary region shared by every stack."
  value       = var.location
}

output "state_resource_group_name" {
  description = "Resource group holding Terraform state."
  value       = azurerm_resource_group.tfstate.name
}

output "state_storage_account_name" {
  description = "Storage account holding Terraform state."
  value       = azurerm_storage_account.tfstate.name
}

output "state_container_name" {
  description = "Blob container holding Terraform state."
  value       = azurerm_storage_container.tfstate.name
}

output "github_identity_client_id" {
  description = "Client ID that GitHub Actions presents when exchanging its OIDC token."
  value       = azurerm_user_assigned_identity.github.client_id
}

output "github_identity_principal_id" {
  description = "Object ID of the deploy identity, for role-assignment checks."
  value       = azurerm_user_assigned_identity.github.principal_id
}

output "root_management_group_id" {
  description = "Resource ID of the intermediate root management group."
  value       = azurerm_management_group.root.id
}

output "group_object_ids" {
  description = "Object IDs of the Entra ID security groups, keyed by role."
  value       = { for key, group in azuread_group.this : key => group.object_id }
}
