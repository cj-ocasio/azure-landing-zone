variable "prefix" {
  type        = string
  description = "Naming prefix; child management group IDs become <prefix>-<name>."
}

variable "root_management_group_id" {
  type        = string
  description = "Resource ID of the intermediate root management group created in bootstrap."
}

variable "subscription_placement" {
  type = map(object({
    subscription_id  = string
    management_group = string
  }))
  description = "Subscriptions to place, keyed by label. management_group is platform, corp, sandbox or decommissioned."

  validation {
    condition = alltrue([
      for placement in values(var.subscription_placement) :
      contains(["platform", "corp", "sandbox", "decommissioned"], placement.management_group)
    ])
    error_message = "management_group must be platform, corp, sandbox or decommissioned."
  }
}
