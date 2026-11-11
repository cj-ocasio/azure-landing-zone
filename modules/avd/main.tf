locals {
  name        = "${var.prefix}-avd-${var.environment}"
  host_prefix = "${var.prefix}avd${var.environment}"
  host_names  = [for index in range(var.session_host_count) : format("%s%02d", local.host_prefix, index + 1)]

  rdp_properties = join(";", [
    var.entra_sso_enabled ? "enablerdsaadauth:i:1" : "targetisaadjoined:i:1",
    "redirectclipboard:i:1",
    "drivestoredirect:s:",
    "redirectprinters:i:0",
    "audiomode:i:0",
    "audiocapturemode:i:1",
  ])
}

resource "azurerm_resource_group" "avd" {
  name     = "rg-${local.name}"
  location = var.location
  tags     = var.tags
}

# ---------------------------------------------------------------------------
# Explicit egress: the subnet is private, so hosts reach the AVD service via NAT.
# The gateway and its IP are pinned to the same zone so the pairing is always valid.
# ---------------------------------------------------------------------------

resource "azurerm_public_ip" "nat" {
  count = var.nat_gateway_enabled ? 1 : 0

  name                = "pip-${local.name}-nat"
  location            = azurerm_resource_group.avd.location
  resource_group_name = azurerm_resource_group.avd.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
  tags                = var.tags
}

resource "azurerm_nat_gateway" "this" {
  count = var.nat_gateway_enabled ? 1 : 0

  name                    = "ng-${local.name}"
  location                = azurerm_resource_group.avd.location
  resource_group_name     = azurerm_resource_group.avd.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 4
  zones                   = ["1"]
  tags                    = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  count = var.nat_gateway_enabled ? 1 : 0

  nat_gateway_id       = azurerm_nat_gateway.this[0].id
  public_ip_address_id = azurerm_public_ip.nat[0].id
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  count = var.nat_gateway_enabled ? 1 : 0

  subnet_id      = var.subnet_id
  nat_gateway_id = azurerm_nat_gateway.this[0].id
}

# ---------------------------------------------------------------------------
# Control plane: host pool, registration token, desktop application group, workspace
# ---------------------------------------------------------------------------

resource "azurerm_virtual_desktop_host_pool" "this" {
  name                     = "vdpool-${local.name}"
  location                 = azurerm_resource_group.avd.location
  resource_group_name      = azurerm_resource_group.avd.name
  friendly_name            = "Landing zone desktops (${var.environment})"
  description              = "Pooled Windows 11 multi-session host pool."
  type                     = "Pooled"
  load_balancer_type       = "BreadthFirst"
  maximum_sessions_allowed = var.max_sessions_per_host
  preferred_app_group_type = "Desktop"
  validate_environment     = var.environment != "prod"
  start_vm_on_connect      = false
  custom_rdp_properties    = local.rdp_properties
  tags                     = var.tags
}

resource "time_rotating" "registration_token" {
  rotation_days = 2
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "this" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.this.id
  expiration_date = time_rotating.registration_token.rotation_rfc3339
}

resource "azurerm_virtual_desktop_application_group" "desktop" {
  name                         = "vdag-${local.name}-desktop"
  location                     = azurerm_resource_group.avd.location
  resource_group_name          = azurerm_resource_group.avd.name
  host_pool_id                 = azurerm_virtual_desktop_host_pool.this.id
  type                         = "Desktop"
  friendly_name                = "Desktop (${var.environment})"
  default_desktop_display_name = "Landing Zone Desktop (${var.environment})"
  tags                         = var.tags
}

resource "azurerm_virtual_desktop_workspace" "this" {
  name                = "vdws-${local.name}"
  location            = azurerm_resource_group.avd.location
  resource_group_name = azurerm_resource_group.avd.name
  friendly_name       = "Landing Zone (${var.environment})"
  tags                = var.tags
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "desktop" {
  workspace_id         = azurerm_virtual_desktop_workspace.this.id
  application_group_id = azurerm_virtual_desktop_application_group.desktop.id
}

# ---------------------------------------------------------------------------
# Data plane: Entra-joined Windows 11 multi-session hosts
# ---------------------------------------------------------------------------

resource "random_password" "local_admin" {
  length           = 24
  special          = true
  override_special = "!@#%^*-_=+"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}

resource "azurerm_network_interface" "session_host" {
  count = var.session_host_count

  name                           = "nic-${local.host_names[count.index]}"
  location                       = azurerm_resource_group.avd.location
  resource_group_name            = azurerm_resource_group.avd.name
  accelerated_networking_enabled = true
  tags                           = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "session_host" {
  count = var.session_host_count

  name                  = "vm-${local.host_names[count.index]}"
  computer_name         = local.host_names[count.index]
  location              = azurerm_resource_group.avd.location
  resource_group_name   = azurerm_resource_group.avd.name
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = random_password.local_admin.result
  network_interface_ids = [azurerm_network_interface.session_host[count.index].id]
  license_type          = "Windows_Client"
  secure_boot_enabled   = true
  vtpm_enabled          = true
  tags                  = var.tags
  disk_controller_type  = var.disk_controller_type

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "osdisk-${local.host_names[count.index]}"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = var.image_sku
    version   = "latest"
  }

  # Hosts must have egress before their extensions try to reach the AVD service.
  depends_on = [azurerm_subnet_nat_gateway_association.this]
}

resource "azurerm_virtual_machine_extension" "avd_registration" {
  count = var.session_host_count

  name                       = "AVDRegistration"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true
  tags                       = var.tags

  settings = jsonencode({
    modulesUrl            = var.dsc_configuration_url
    configurationFunction = "Configuration.ps1\\AddSessionHost"
    properties = {
      HostPoolName             = azurerm_virtual_desktop_host_pool.this.name
      aadJoin                  = true
      UseAgentDownloadEndpoint = true
    }
  })

  protected_settings = jsonencode({
    properties = {
      registrationInfoToken = azurerm_virtual_desktop_host_pool_registration_info.this.token
    }
  })

  # Token rotation must not re-run registration on hosts that are already registered.
  lifecycle {
    ignore_changes = [settings, protected_settings]
  }
}

resource "azurerm_virtual_machine_extension" "entra_login" {
  count = var.session_host_count

  name                       = "AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true
  tags                       = var.tags

  # Extensions on one VM must run one at a time; registration first, then the Entra join.
  depends_on = [azurerm_virtual_machine_extension.avd_registration]
}

# ---------------------------------------------------------------------------
# Access: who sees the desktop, and who may sign in to the hosts
# ---------------------------------------------------------------------------

resource "azurerm_role_assignment" "desktop_users" {
  scope                = azurerm_virtual_desktop_application_group.desktop.id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = var.users_group_object_id
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "vm_user_login" {
  scope                = azurerm_resource_group.avd.id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = var.users_group_object_id
  principal_type       = "Group"
}
