data "terraform_remote_state" "governance" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.tfstate_resource_group_name
    storage_account_name = var.tfstate_storage_account_name
    container_name       = var.tfstate_container_name
    key                  = "governance.tfstate"
    subscription_id      = var.platform_subscription_id
    use_azuread_auth     = true
  }
}
