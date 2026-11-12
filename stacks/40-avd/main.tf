locals {
  bootstrap = data.terraform_remote_state.bootstrap.outputs
  spoke     = data.terraform_remote_state.connectivity.outputs.spokes["avd-${var.environment}"]

  workload_subscription_id = {
    dev  = var.lz_dev_subscription_id
    prod = var.lz_prod_subscription_id
  }[var.environment]
}

module "avd" {
  source = "../../modules/avd"

  prefix                = local.bootstrap.prefix
  environment           = var.environment
  location              = local.bootstrap.location
  subnet_id             = local.spoke.subnet_ids["snet-avd-hosts"]
  users_group_object_id = local.bootstrap.group_object_ids["avd_users_${var.environment}"]
  session_host_count    = var.session_host_count
  vm_size               = var.vm_size
  disk_controller_type  = var.disk_controller_type
  image_sku             = var.image_sku
  dsc_configuration_url = var.dsc_configuration_url
  entra_sso_enabled     = var.entra_sso_enabled
  nat_gateway_enabled   = var.nat_gateway_enabled

  tags = {
    environment = var.environment
    managed-by  = "terraform"
    workload    = "avd"
  }
}
