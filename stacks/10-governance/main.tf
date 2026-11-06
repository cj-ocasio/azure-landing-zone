locals {
  bootstrap = data.terraform_remote_state.bootstrap.outputs
}

module "management_groups" {
  source = "../../modules/management-groups"

  prefix                   = local.bootstrap.prefix
  root_management_group_id = local.bootstrap.root_management_group_id

  subscription_placement = {
    platform = {
      subscription_id  = var.platform_subscription_id
      management_group = "platform"
    }
    lz_dev = {
      subscription_id  = var.lz_dev_subscription_id
      management_group = "corp"
    }
    lz_prod = {
      subscription_id  = var.lz_prod_subscription_id
      management_group = "corp"
    }
  }
}

module "policy_baseline" {
  source = "../../modules/policy-baseline"

  prefix                   = local.bootstrap.prefix
  root_management_group_id = local.bootstrap.root_management_group_id
  corp_management_group_id = module.management_groups.management_group_ids["corp"]
  allowed_locations        = var.allowed_locations
  required_tag_name        = var.required_tag_name
}
