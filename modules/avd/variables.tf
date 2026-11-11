variable "prefix" {
  type        = string
  description = "Naming prefix; 2-6 characters keeps session-host names within the Windows 15-character limit."
}

variable "environment" {
  type        = string
  description = "Environment name: dev or prod."

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

variable "location" {
  type        = string
  description = "Azure region; must also be a supported AVD metadata location."
}

variable "subnet_id" {
  type        = string
  description = "Private subnet for the session hosts, from the connectivity stack."
}

variable "users_group_object_id" {
  type        = string
  description = "Entra group whose members may use the desktop."
}

variable "session_host_count" {
  type        = number
  description = "Number of session hosts; 0 deploys the control plane only."
  default     = 1

  validation {
    condition     = var.session_host_count >= 0 && var.session_host_count <= 10
    error_message = "session_host_count must be between 0 and 10."
  }
}

variable "vm_size" {
  type        = string
  description = "Session-host VM size."
  default     = "Standard_D2s_v5"
}

variable "image_sku" {
  type        = string
  description = "Windows 11 multi-session SKU in MicrosoftWindowsDesktop/windows-11."
  default     = "win11-24h2-avd"
}

variable "max_sessions_per_host" {
  type        = number
  description = "Maximum concurrent sessions per host."
  default     = 4
}

variable "admin_username" {
  type        = string
  description = "Break-glass local administrator name."
  default     = "avdadmin"
}

variable "dsc_configuration_url" {
  type        = string
  description = "AVD registration package used by the DSC extension (see B6.2)."
  default     = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02655.277.zip"
}

variable "entra_sso_enabled" {
  type        = bool
  description = "Use Microsoft Entra single sign-on for RDP (requires B6.5). false falls back to targetisaadjoined."
  default     = true
}

variable "nat_gateway_enabled" {
  type        = bool
  description = "Create a NAT Gateway for explicit egress from the private subnet."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to every resource."
}

variable "disk_controller_type" {
  type        = string
  description = "Session-host disk controller: SCSI, or NVMe for v6/v7 sizes that support only NVMe."
  default     = "SCSI"

  validation {
    condition     = contains(["SCSI", "NVMe"], var.disk_controller_type)
    error_message = "disk_controller_type must be SCSI or NVMe."
  }
}
