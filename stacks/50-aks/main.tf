locals {
  bootstrap = data.terraform_remote_state.bootstrap.outputs
  network   = data.terraform_remote_state.connectivity.outputs
  spoke     = local.network.spokes["aks-${var.environment}"]
  aks_zone  = "privatelink.${local.bootstrap.location}.azmk8s.io"
}

module "aks" {
  source = "../../modules/aks-cluster"

  prefix                = local.bootstrap.prefix
  environment           = var.environment
  location              = local.bootstrap.location
  tenant_id             = local.bootstrap.tenant_id
  subnet_id             = local.spoke.subnet_ids["snet-aks-nodes"]
  vnet_id               = local.spoke.vnet_id
  private_dns_zone_id   = local.network.private_dns_zone_ids[local.aks_zone]
  admin_group_object_id = local.bootstrap.group_object_ids["aks_admins"]
  api_server_mode       = var.api_server_mode
  authorized_ip_ranges  = var.authorized_ip_ranges
  kubernetes_version    = var.kubernetes_version
  node_vm_size          = var.node_vm_size
  node_count            = var.node_count

  tags = {
    environment = var.environment
    managed-by  = "terraform"
    workload    = "aks"
  }
}
