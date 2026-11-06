data "azurerm_policy_definition" "allowed_locations" {
  display_name = "Allowed locations"
}

data "azurerm_policy_definition" "storage_secure_transfer" {
  display_name = "Secure transfer to storage accounts should be enabled"
}

data "azurerm_policy_definition" "nic_no_public_ip" {
  display_name = "Network interfaces should not have public IPs"
}

# Authored policy: resource groups must carry a named tag. Audit by default.
resource "azurerm_policy_definition" "rg_required_tag" {
  name                = "${var.prefix}-rg-required-tag"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Resource groups should carry a required tag"
  description         = "Audits, or denies, resource groups that are missing the named tag."
  management_group_id = var.root_management_group_id

  metadata = jsonencode({
    category = "Tags"
    version  = "1.0.0"
  })

  parameters = jsonencode({
    tagName = {
      type = "String"
      metadata = {
        displayName = "Tag name"
        description = "Tag that must exist on every resource group."
      }
    }
    effect = {
      type          = "String"
      allowedValues = ["Audit", "Deny", "Disabled"]
      defaultValue  = "Audit"
      metadata = {
        displayName = "Effect"
        description = "Audit reports non-compliance; Deny blocks creation."
      }
    }
  })

  policy_rule = jsonencode({
    "if" = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Resources/subscriptions/resourceGroups"
        },
        {
          field  = "[concat('tags[', parameters('tagName'), ']')]"
          exists = "false"
        },
      ]
    }
    "then" = {
      effect = "[parameters('effect')]"
    }
  })
}

# Assignment names at management-group scope are limited to 24 characters.

resource "azurerm_management_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  display_name         = "Allowed locations"
  description          = "Deny resources outside the approved regions."
  management_group_id  = var.root_management_group_id
  policy_definition_id = data.azurerm_policy_definition.allowed_locations.id

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = var.allowed_locations
    }
  })

  non_compliance_message {
    content = "Deploy only to approved regions: ${join(", ", var.allowed_locations)}."
  }
}

resource "azurerm_management_group_policy_assignment" "rg_required_tag" {
  name                 = "rg-required-tag"
  display_name         = "Resource groups must carry the '${var.required_tag_name}' tag"
  description          = "Audit-only tag hygiene; switch the effect to Deny once everything is compliant."
  management_group_id  = var.root_management_group_id
  policy_definition_id = azurerm_policy_definition.rg_required_tag.id

  parameters = jsonencode({
    tagName = {
      value = var.required_tag_name
    }
    effect = {
      value = "Audit"
    }
  })
}

resource "azurerm_management_group_policy_assignment" "storage_secure_transfer" {
  name                 = "storage-secure-xfer"
  display_name         = "Secure transfer to storage accounts should be enabled"
  management_group_id  = var.root_management_group_id
  policy_definition_id = data.azurerm_policy_definition.storage_secure_transfer.id
}

resource "azurerm_management_group_policy_assignment" "corp_deny_nic_public_ip" {
  name                 = "deny-nic-public-ip"
  display_name         = "Corp: network interfaces must not have public IPs"
  description          = "Corp landing zones reach the internet only through explicit egress."
  management_group_id  = var.corp_management_group_id
  policy_definition_id = data.azurerm_policy_definition.nic_no_public_ip.id

  non_compliance_message {
    content = "Public IPs on network interfaces are not allowed in corp landing zones; use NAT Gateway for egress."
  }
}
