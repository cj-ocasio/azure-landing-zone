# Identical in every stack: where state lives, plus the bootstrap outputs every stack consumes.

variable "tfstate_resource_group_name" {
  type        = string
  description = "Resource group of the Terraform state storage account."
}

variable "tfstate_storage_account_name" {
  type        = string
  description = "Terraform state storage account."
}

variable "tfstate_container_name" {
  type        = string
  description = "Terraform state blob container."
}

variable "platform_subscription_id" {
  type        = string
  description = "Platform subscription; it also holds Terraform state."
}

data "terraform_remote_state" "bootstrap" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.tfstate_resource_group_name
    storage_account_name = var.tfstate_storage_account_name
    container_name       = var.tfstate_container_name
    key                  = "bootstrap.tfstate"
    subscription_id      = var.platform_subscription_id
    use_azuread_auth     = true
  }
}
