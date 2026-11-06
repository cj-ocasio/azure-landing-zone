variable "custom_role_name" {
  type        = string
  description = "Tenant-unique name of the Landing Zone Operator custom role."
}

variable "custom_role_scope" {
  type        = string
  description = "Management group ID where the custom role is defined and assignable."
}

variable "role_assignments" {
  type = map(object({
    scope                = string
    principal_id         = string
    role_definition_name = optional(string)
    use_custom_role      = optional(bool, false)
    description          = optional(string)
  }))
  description = "Role assignments keyed by a stable name. Set role_definition_name for built-in roles, or use_custom_role = true."

  validation {
    condition = alltrue([
      for assignment in values(var.role_assignments) :
      assignment.use_custom_role || assignment.role_definition_name != null
    ])
    error_message = "Each assignment needs role_definition_name unless use_custom_role is true."
  }
}
