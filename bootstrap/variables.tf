variable "tenant_id" {
  type        = string
  description = "Entra ID tenant that hosts the landing zone."
}

variable "platform_subscription_id" {
  type        = string
  description = "Platform subscription: connectivity, DNS and Terraform state."
}

variable "lz_dev_subscription_id" {
  type        = string
  description = "Corp landing-zone subscription for dev workloads."
}

variable "lz_prod_subscription_id" {
  type        = string
  description = "Corp landing-zone subscription for prod workloads."
}

variable "prefix" {
  type        = string
  description = "Short lowercase naming prefix used by every resource (2-6 characters)."

  validation {
    condition     = can(regex("^[a-z0-9]{2,6}$", var.prefix))
    error_message = "prefix must be 2-6 lowercase letters or digits."
  }
}

variable "location" {
  type        = string
  description = "Primary Azure region."
  default     = "eastus2"
}

variable "github_owner" {
  type        = string
  description = "GitHub user or organization that owns the repository."
}

variable "github_repo" {
  type        = string
  description = "Repository name without the owner."
}

variable "github_environments" {
  type        = list(string)
  description = "GitHub environments whose jobs may request Azure tokens."
  default     = ["platform", "dev", "prod"]
}

variable "root_management_group_display_name" {
  type        = string
  description = "Display name of the intermediate root management group."
  default     = "Landing Zone Root"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to bootstrap resources."
  default = {
    environment = "platform"
    managed-by  = "terraform"
    workload    = "bootstrap"
  }
}

variable "github_owner_id" {
  type        = string
  description = "Numeric GitHub ID of the repository owner, used in immutable OIDC subjects."
}

variable "github_repo_id" {
  type        = string
  description = "Numeric GitHub ID of the repository, used in immutable OIDC subjects."
}