provider "azurerm" {
  features {}

  subscription_id = var.platform_subscription_id
}

provider "azurerm" {
  alias = "lz_dev"
  features {}

  subscription_id = var.lz_dev_subscription_id
}

provider "azurerm" {
  alias = "lz_prod"
  features {}

  subscription_id = var.lz_prod_subscription_id
}
