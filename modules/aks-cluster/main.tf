locals {
  name       = "${var.prefix}-aks-${var.environment}"
  is_private = var.api_server_mode == "private"
}

resource "azurerm_resource_group" "aks" {
  name     = "rg-${local.name}"
  location = var.location
  tags     = var.tags
}

# ---------------------------------------------------------------------------
# Control-plane identity and the rights it needs before the cluster exists
# ---------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "control_plane" {
  name                = "id-${local.name}-control-plane"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  tags                = var.tags
}

resource "azurerm_role_assignment" "spoke_network_contributor" {
  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.control_plane.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "private_dns_zone_contributor" {
  count = local.is_private ? 1 : 0

  scope                = var.private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.control_plane.principal_id
  principal_type       = "ServicePrincipal"
}

resource "time_sleep" "rbac_propagation" {
  create_duration = "120s"

  depends_on = [
    azurerm_role_assignment.spoke_network_contributor,
    azurerm_role_assignment.private_dns_zone_contributor,
  ]
}

# ---------------------------------------------------------------------------
# Cluster
# ---------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "this" {
  name                      = "aks-${var.prefix}-${var.environment}"
  location                  = azurerm_resource_group.aks.location
  resource_group_name       = azurerm_resource_group.aks.name
  node_resource_group       = "rg-${local.name}-nodes"
  dns_prefix                = "aks-${var.prefix}-${var.environment}"
  kubernetes_version        = var.kubernetes_version
  sku_tier                  = "Free"
  private_cluster_enabled   = local.is_private
  private_dns_zone_id       = local.is_private ? var.private_dns_zone_id : null
  local_account_disabled    = true
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  automatic_upgrade_channel = "patch"
  node_os_upgrade_channel   = "NodeImage"
  tags                      = var.tags

  default_node_pool {
    name                        = "system"
    vm_size                     = var.node_vm_size
    node_count                  = var.node_count
    vnet_subnet_id              = var.subnet_id
    temporary_name_for_rotation = "systemtmp"

    upgrade_settings {
      max_surge = "10%"
    }
  }

  # Required since AzureRM 5.0. Manual keeps classic node pools (no node auto-provisioning).
  node_provisioning_profile {
    mode = "Manual"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.control_plane.id]
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    tenant_id              = var.tenant_id
    admin_group_object_ids = [var.admin_group_object_id]
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"
    network_policy      = "cilium"
    pod_cidr            = var.pod_cidr
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
  }

  dynamic "api_server_access_profile" {
    for_each = local.is_private ? [] : [var.authorized_ip_ranges]

    content {
      authorized_ip_ranges = api_server_access_profile.value
    }
  }

  depends_on = [time_sleep.rbac_propagation]
}

# ---------------------------------------------------------------------------
# Who may operate the cluster
# ---------------------------------------------------------------------------

resource "azurerm_role_assignment" "admins_cluster_admin" {
  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = var.admin_group_object_id
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "admins_cluster_user" {
  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = var.admin_group_object_id
  principal_type       = "Group"
}
