variable "lz_dev_subscription_id" {
  type        = string
  description = "Corp landing-zone subscription for dev workloads."
}

variable "lz_prod_subscription_id" {
  type        = string
  description = "Corp landing-zone subscription for prod workloads."
}

variable "environment" {
  type        = string
  description = "Target environment: dev or prod."

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

variable "session_host_count" {
  type        = number
  description = "Number of session hosts in this environment."
}

variable "vm_size" {
  type        = string
  description = "Session-host VM size."
  default     = "Standard_D2s_v5"
}

variable "image_sku" {
  type        = string
  description = "Windows 11 multi-session SKU."
  default     = "win11-24h2-avd"
}

variable "dsc_configuration_url" {
  type        = string
  description = "AVD registration package URL (see B6.2)."
  default     = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02655.277.zip"
}

variable "entra_sso_enabled" {
  type        = bool
  description = "Use Microsoft Entra single sign-on for RDP."
  default     = true
}

variable "nat_gateway_enabled" {
  type        = bool
  description = "Create NAT Gateway egress for the session-host subnet."
  default     = true
}
