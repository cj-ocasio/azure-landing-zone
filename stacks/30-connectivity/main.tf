locals {
  bootstrap = data.terraform_remote_state.bootstrap.outputs
  prefix    = local.bootstrap.prefix
  location  = local.bootstrap.location

  # AKS private clusters require a zone named privatelink.<region>.azmk8s.io.
  private_dns_zones = concat(var.extra_private_dns_zones, ["privatelink.${local.location}.azmk8s.io"])

  hub_for_spokes = {
    vnet_id             = module.hub.vnet_id
    vnet_name           = module.hub.vnet_name
    resource_group_name = module.hub.resource_group_name
  }
}

module "hub" {
  source = "../../modules/hub-network"

  prefix            = local.prefix
  location          = local.location
  address_space     = var.hub_address_space
  subnets           = var.hub_subnets
  private_dns_zones = local.private_dns_zones

  tags = {
    environment = "platform"
    managed-by  = "terraform"
    workload    = "connectivity"
  }
}

module "spoke_avd_dev" {
  source = "../../modules/spoke-network"
  providers = {
    azurerm     = azurerm.lz_dev
    azurerm.hub = azurerm
  }

  name                 = "avd-dev"
  prefix               = local.prefix
  location             = local.location
  address_space        = var.spokes["avd-dev"].address_space
  subnets              = var.spokes["avd-dev"].subnets
  hub                  = local.hub_for_spokes
  private_dns_zone_ids = module.hub.private_dns_zone_ids

  tags = {
    environment = "dev"
    managed-by  = "terraform"
    workload    = "avd"
  }
}

module "spoke_avd_prod" {
  source = "../../modules/spoke-network"
  providers = {
    azurerm     = azurerm.lz_prod
    azurerm.hub = azurerm
  }

  name                 = "avd-prod"
  prefix               = local.prefix
  location             = local.location
  address_space        = var.spokes["avd-prod"].address_space
  subnets              = var.spokes["avd-prod"].subnets
  hub                  = local.hub_for_spokes
  private_dns_zone_ids = module.hub.private_dns_zone_ids

  tags = {
    environment = "prod"
    managed-by  = "terraform"
    workload    = "avd"
  }
}

module "spoke_aks_dev" {
  source = "../../modules/spoke-network"
  providers = {
    azurerm     = azurerm.lz_dev
    azurerm.hub = azurerm
  }

  name                 = "aks-dev"
  prefix               = local.prefix
  location             = local.location
  address_space        = var.spokes["aks-dev"].address_space
  subnets              = var.spokes["aks-dev"].subnets
  hub                  = local.hub_for_spokes
  private_dns_zone_ids = module.hub.private_dns_zone_ids

  tags = {
    environment = "dev"
    managed-by  = "terraform"
    workload    = "aks"
  }
}
