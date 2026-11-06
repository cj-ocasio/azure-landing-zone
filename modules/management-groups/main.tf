resource "azurerm_management_group" "platform" {
  name                       = "${var.prefix}-platform"
  display_name               = "Platform"
  parent_management_group_id = var.root_management_group_id

  lifecycle {
    ignore_changes = [subscription_ids]
  }
}

resource "azurerm_management_group" "landing_zones" {
  name                       = "${var.prefix}-landingzones"
  display_name               = "Landing Zones"
  parent_management_group_id = var.root_management_group_id

  lifecycle {
    ignore_changes = [subscription_ids]
  }
}

resource "azurerm_management_group" "corp" {
  name                       = "${var.prefix}-corp"
  display_name               = "Corp"
  parent_management_group_id = azurerm_management_group.landing_zones.id

  lifecycle {
    ignore_changes = [subscription_ids]
  }
}

resource "azurerm_management_group" "sandbox" {
  name                       = "${var.prefix}-sandbox"
  display_name               = "Sandbox"
  parent_management_group_id = var.root_management_group_id

  lifecycle {
    ignore_changes = [subscription_ids]
  }
}

resource "azurerm_management_group" "decommissioned" {
  name                       = "${var.prefix}-decommissioned"
  display_name               = "Decommissioned"
  parent_management_group_id = var.root_management_group_id

  lifecycle {
    ignore_changes = [subscription_ids]
  }
}

locals {
  management_group_ids = {
    root           = var.root_management_group_id
    platform       = azurerm_management_group.platform.id
    landing_zones  = azurerm_management_group.landing_zones.id
    corp           = azurerm_management_group.corp.id
    sandbox        = azurerm_management_group.sandbox.id
    decommissioned = azurerm_management_group.decommissioned.id
  }
}

resource "azurerm_management_group_subscription_association" "this" {
  for_each = var.subscription_placement

  management_group_id = local.management_group_ids[each.value.management_group]
  subscription_id     = "/subscriptions/${each.value.subscription_id}"
}
