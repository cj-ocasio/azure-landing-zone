output "management_group_ids" {
  description = "Management group IDs keyed by role: root, platform, landing_zones, corp, sandbox, decommissioned."
  value       = module.management_groups.management_group_ids
}

output "policy_assignment_ids" {
  description = "Policy assignment IDs keyed by purpose."
  value       = module.policy_baseline.policy_assignment_ids
}
