output "resource_group_name" {
  description = "Resource group holding the AVD workload."
  value       = module.avd.resource_group_name
}

output "host_pool_name" {
  description = "Host pool name."
  value       = module.avd.host_pool_name
}

output "workspace_name" {
  description = "Workspace name shown to users."
  value       = module.avd.workspace_name
}

output "session_host_names" {
  description = "Computer names of the session hosts."
  value       = module.avd.session_host_names
}

output "nat_public_ip" {
  description = "Egress public IP of the session hosts."
  value       = module.avd.nat_public_ip
}
