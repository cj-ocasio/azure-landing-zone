variable "prefix" {
  type        = string
  description = "Naming prefix for custom policy definitions."
}

variable "root_management_group_id" {
  type        = string
  description = "Intermediate root management group ID; baseline assignments land here."
}

variable "corp_management_group_id" {
  type        = string
  description = "Corp management group ID; corp-only guardrails land here."
}

variable "allowed_locations" {
  type        = list(string)
  description = "Regions resources may be deployed to."
}

variable "required_tag_name" {
  type        = string
  description = "Tag every resource group must carry."
}
