resource "azurerm_resource_group" "hub" {
  name     = "rg-${var.prefix}-connectivity"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${var.prefix}-hub-${var.location}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "hub" {
  for_each = var.subnets

  name                            = each.key
  resource_group_name             = azurerm_resource_group.hub.name
  virtual_network_name            = azurerm_virtual_network.hub.name
  address_prefixes                = [each.value]
  default_outbound_access_enabled = false
}

resource "azurerm_resource_group" "dns" {
  name     = "rg-${var.prefix}-dns"
  location = var.location
  tags     = var.tags
}

resource "azurerm_private_dns_zone" "this" {
  for_each = toset(var.private_dns_zones)

  name                = each.value
  resource_group_name = azurerm_resource_group.dns.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  for_each = azurerm_private_dns_zone.this

  name                 = "link-${azurerm_virtual_network.hub.name}"
  private_dns_zone_id  = each.value.id
  virtual_network_id   = azurerm_virtual_network.hub.id
  registration_enabled = false
  tags                 = var.tags
}
