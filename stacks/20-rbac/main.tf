locals {
  bootstrap = data.terraform_remote_state.bootstrap.outputs
  mg        = data.terraform_remote_state.governance.outputs.management_group_ids
  groups    = local.bootstrap.group_object_ids
}

module "rbac" {
  source = "../../modules/rbac"

  custom_role_name  = "Landing Zone Operator (${local.bootstrap.prefix})"
  custom_role_scope = local.mg["root"]

  role_assignments = {
    readers_root = {
      scope                = local.mg["root"]
      role_definition_name = "Reader"
      principal_id         = local.groups["readers"]
      description          = "Read-only visibility across the landing zone."
    }
    platform_engineers_platform = {
      scope                = local.mg["platform"]
      role_definition_name = "Contributor"
      principal_id         = local.groups["platform_engineers"]
      description          = "Platform engineers manage shared platform resources."
    }
    platform_engineers_lz_network = {
      scope                = local.mg["landing_zones"]
      role_definition_name = "Network Contributor"
      principal_id         = local.groups["platform_engineers"]
      description          = "Platform engineers manage spoke networking inside landing zones."
    }
    lz_operators_landing_zones = {
      scope           = local.mg["landing_zones"]
      use_custom_role = true
      principal_id    = local.groups["lz_operators"]
      description     = "Operators run day-2 tasks without create or delete rights."
    }
  }
}
