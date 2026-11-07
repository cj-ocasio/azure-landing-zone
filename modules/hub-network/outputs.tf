output "resource_group_name" {
  description = "Resource group holding the hub VNet."
  value       = azurerm_resource_group.hub.name
}

output "vnet_id" {
  description = "Hub VNet resource ID."
  value       = azurerm_virtual_network.hub.id
}

output "vnet_name" {
  description = "Hub VNet name."
  value       = azurerm_virtual_network.hub.name
}

output "dns_resource_group_name" {
  description = "Resource group holding the private DNS zones."
  value       = azurerm_resource_group.dns.name
}

output "private_dns_zone_ids" {
  description = "Private DNS zone IDs keyed by zone name."
  value       = { for name, zone in azurerm_private_dns_zone.this : name => zone.id }
}
