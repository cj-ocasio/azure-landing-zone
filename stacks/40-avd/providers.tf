provider "azurerm" {
  features {}

  subscription_id = local.workload_subscription_id
}
