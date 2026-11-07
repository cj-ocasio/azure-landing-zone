output "resource_group_name" {
  description = "Resource group holding the spoke VNet."
  value       = azurerm_resource_group.spoke.name
}

output "vnet_id" {
  description = "Spoke VNet resource ID."
  value       = azurerm_virtual_network.spoke.id
}

output "vnet_name" {
  description = "Spoke VNet name."
  value       = azurerm_virtual_network.spoke.name
}

output "subnet_ids" {
  description = "Subnet IDs keyed by subnet name."
  value       = { for name, subnet in azurerm_subnet.spoke : name => subnet.id }
}
