data "azurerm_client_config" "current" {}

data "azuread_client_config" "current" {}

locals {
  subscriptions = {
    platform = var.platform_subscription_id
    lz_dev   = var.lz_dev_subscription_id
    lz_prod  = var.lz_prod_subscription_id
  }

  repo = "${var.github_owner}/${var.github_repo}"

  # One federated credential per OIDC subject GitHub will present.
  github_subjects = merge(
    { "branch-main" = "repo:${local.repo}:ref:refs/heads/main" },
    { for env in var.github_environments : "env-${env}" => "repo:${local.repo}:environment:${env}" }
  )

  groups = {
    platform_engineers = "Platform engineers: contributor on the platform management group."
    lz_operators       = "Landing-zone operators: custom operator role on landing zones."
    readers            = "Read-only visibility across the landing zone."
    avd_users_dev      = "Azure Virtual Desktop users (dev)."
    avd_users_prod     = "Azure Virtual Desktop users (prod)."
    aks_admins         = "AKS cluster administrators."
  }

  # You join these two groups so that you can test AVD dev and administer AKS.
  groups_including_operator = ["avd_users_dev", "aks_admins"]
}

# ---------------------------------------------------------------------------
# Terraform state: resource group, storage account, container, delete lock
# ---------------------------------------------------------------------------

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_resource_group" "tfstate" {
  name     = "rg-${var.prefix}-tfstate"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "tfstate" {
  name                            = "st${var.prefix}tfstate${random_string.suffix.result}"
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = "Standard"
  account_replication_type        = "ZRS"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  default_to_oauth_authentication = true
  tags                            = var.tags

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

resource "azurerm_management_lock" "tfstate" {
  name       = "lock-tfstate-cannotdelete"
  scope      = azurerm_storage_account.tfstate.id
  lock_level = "CanNotDelete"
  notes      = "Protects Terraform state for every landing-zone stack."
}

resource "azurerm_role_assignment" "operator_state_data" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "User"
}

# ---------------------------------------------------------------------------
# Deploy identity for GitHub Actions (OIDC, no secrets)
# ---------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "github" {
  name                = "id-${var.prefix}-github-deploy"
  resource_group_name = azurerm_resource_group.tfstate.name
  location            = azurerm_resource_group.tfstate.location
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "github" {
  for_each = local.github_subjects

  name                      = "gh-${each.key}"
  user_assigned_identity_id = azurerm_user_assigned_identity.github.id
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = "https://token.actions.githubusercontent.com"
  subject                   = each.value
}

resource "azurerm_role_assignment" "github_state_data" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
  principal_type       = "ServicePrincipal"
}

# ---------------------------------------------------------------------------
# Intermediate root management group and the deploy identity's scope
# ---------------------------------------------------------------------------

resource "azurerm_management_group" "root" {
  name         = var.prefix
  display_name = var.root_management_group_display_name

  lifecycle {
    ignore_changes = [subscription_ids]
  }
}

resource "azurerm_role_assignment" "github_owner_root_mg" {
  scope                = azurerm_management_group.root.id
  role_definition_name = "Owner"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
  principal_type       = "ServicePrincipal"
}

# Subscriptions start under the tenant root, so the identity needs Owner on each
# one before the governance stack can move them into the hierarchy.
resource "azurerm_role_assignment" "github_owner_subscriptions" {
  for_each = local.subscriptions

  scope                = "/subscriptions/${each.value}"
  role_definition_name = "Owner"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
  principal_type       = "ServicePrincipal"
}

# ---------------------------------------------------------------------------
# Entra ID security groups: the identity plane, owned by a human, not the pipeline
# ---------------------------------------------------------------------------

resource "azuread_group" "this" {
  for_each = local.groups

  display_name     = "grp-${var.prefix}-${replace(each.key, "_", "-")}"
  description      = each.value
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]

  # A list makes membership authoritative (Terraform removes anyone not listed);
  # null leaves membership unmanaged so you can add test users by hand.
  members = contains(local.groups_including_operator, each.key) ? [data.azuread_client_config.current.object_id] : null
}
