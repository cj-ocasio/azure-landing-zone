resource "azurerm_resource_group" "spoke" {
  name     = "rg-${var.prefix}-${var.name}-network"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-${var.prefix}-${var.name}-${var.location}"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_network_security_group" "spoke" {
  for_each = var.subnets

  name                = "nsg-${var.prefix}-${var.name}-${each.key}"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  tags                = var.tags
}

resource "azurerm_subnet" "spoke" {
  for_each = var.subnets

  name                            = each.key
  resource_group_name             = azurerm_resource_group.spoke.name
  virtual_network_name            = azurerm_virtual_network.spoke.name
  address_prefixes                = [each.value]
  default_outbound_access_enabled = false
}

resource "azurerm_subnet_network_security_group_association" "spoke" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.spoke[each.key].id
  network_security_group_id = azurerm_network_security_group.spoke[each.key].id
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "peer-${var.name}-to-hub"
  resource_group_name          = azurerm_resource_group.spoke.name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = var.hub.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  provider = azurerm.hub

  name                         = "peer-hub-to-${var.name}"
  resource_group_name          = var.hub.resource_group_name
  virtual_network_name         = var.hub.vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke" {
  provider = azurerm.hub
  for_each = var.private_dns_zone_ids

  name                 = "link-${azurerm_virtual_network.spoke.name}"
  private_dns_zone_id  = each.value
  virtual_network_id   = azurerm_virtual_network.spoke.id
  registration_enabled = false
  tags                 = var.tags
}
