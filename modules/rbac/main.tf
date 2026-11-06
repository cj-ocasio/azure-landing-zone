resource "azurerm_role_definition" "lz_operator" {
  name              = var.custom_role_name
  scope             = var.custom_role_scope
  description       = "Day-2 operations on landing-zone workloads: read everything, power-cycle VMs, drain hosts and sign out AVD sessions. Cannot create or delete resources."
  assignable_scopes = [var.custom_role_scope]

  permissions {
    actions = [
      "*/read",
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/restart/action",
      "Microsoft.Compute/virtualMachines/deallocate/action",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/write",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/delete",
      "Microsoft.Support/*",
    ]
  }
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                = each.value.scope
  role_definition_name = each.value.use_custom_role ? null : each.value.role_definition_name
  role_definition_id   = each.value.use_custom_role ? azurerm_role_definition.lz_operator.role_definition_resource_id : null
  principal_id         = each.value.principal_id
  principal_type       = "Group"
  description          = each.value.description
}
