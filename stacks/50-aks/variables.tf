variable "lz_dev_subscription_id" {
  type        = string
  description = "Corp landing-zone subscription for dev workloads."
}

variable "environment" {
  type        = string
  description = "Target environment; this build deploys AKS to dev only."

  validation {
    condition     = var.environment == "dev"
    error_message = "This stack deploys AKS to dev only."
  }
}

variable "api_server_mode" {
  type        = string
  description = "private or public."
  default     = "private"
}

variable "authorized_ip_ranges" {
  type        = list(string)
  description = "CIDRs allowed to reach a public API server."
  default     = []
}

variable "kubernetes_version" {
  type        = string
  description = "AKS version; null uses the regional default."
  default     = null
}

variable "node_vm_size" {
  type        = string
  description = "System node pool VM size."
  default     = "Standard_D2s_v5"
}

variable "node_count" {
  type        = number
  description = "System node pool size."
  default     = 1
}
