output "resource_group_name" {
  description = "Resource group holding the AVD workload."
  value       = azurerm_resource_group.avd.name
}

output "host_pool_name" {
  description = "Host pool name."
  value       = azurerm_virtual_desktop_host_pool.this.name
}

output "workspace_name" {
  description = "Workspace name shown to users."
  value       = azurerm_virtual_desktop_workspace.this.name
}

output "session_host_names" {
  description = "Computer names of the session hosts."
  value       = local.host_names
}

output "nat_public_ip" {
  description = "Egress public IP of the session hosts; null when NAT is disabled."
  value       = try(azurerm_public_ip.nat[0].ip_address, null)
}
