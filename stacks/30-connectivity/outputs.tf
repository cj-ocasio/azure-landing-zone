output "hub" {
  description = "Hub network identifiers."
  value       = local.hub_for_spokes
}

output "dns_resource_group_name" {
  description = "Resource group holding the private DNS zones."
  value       = module.hub.dns_resource_group_name
}

output "private_dns_zone_ids" {
  description = "Private DNS zone IDs keyed by zone name."
  value       = module.hub.private_dns_zone_ids
}

output "spokes" {
  description = "Spoke network identifiers keyed by spoke name."
  value = {
    "avd-dev" = {
      vnet_id    = module.spoke_avd_dev.vnet_id
      subnet_ids = module.spoke_avd_dev.subnet_ids
    }
    "avd-prod" = {
      vnet_id    = module.spoke_avd_prod.vnet_id
      subnet_ids = module.spoke_avd_prod.subnet_ids
    }
    "aks-dev" = {
      vnet_id    = module.spoke_aks_dev.vnet_id
      subnet_ids = module.spoke_aks_dev.subnet_ids
    }
  }
}
