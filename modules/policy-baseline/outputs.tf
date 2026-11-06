output "policy_assignment_ids" {
  description = "Policy assignment IDs keyed by purpose."
  value = {
    allowed_locations       = azurerm_management_group_policy_assignment.allowed_locations.id
    rg_required_tag         = azurerm_management_group_policy_assignment.rg_required_tag.id
    storage_secure_transfer = azurerm_management_group_policy_assignment.storage_secure_transfer.id
    corp_deny_nic_public_ip = azurerm_management_group_policy_assignment.corp_deny_nic_public_ip.id
  }
}
