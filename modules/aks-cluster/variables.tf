variable "prefix" {
  type        = string
  description = "Naming prefix."
}

variable "environment" {
  type        = string
  description = "Environment name."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "tenant_id" {
  type        = string
  description = "Entra tenant used for cluster authentication."
}

variable "subnet_id" {
  type        = string
  description = "Node subnet, from the connectivity stack."
}

variable "vnet_id" {
  type        = string
  description = "Spoke VNet that contains the node subnet."
}

variable "private_dns_zone_id" {
  type        = string
  description = "Hub private DNS zone privatelink.<region>.azmk8s.io; used when api_server_mode is private."
}

variable "admin_group_object_id" {
  type        = string
  description = "Entra group granted cluster-admin through Azure RBAC."
}

variable "api_server_mode" {
  type        = string
  description = "private: API reachable only inside the network. public: restricted by authorized_ip_ranges."
  default     = "private"

  validation {
    condition     = contains(["private", "public"], var.api_server_mode)
    error_message = "api_server_mode must be private or public."
  }
}

variable "authorized_ip_ranges" {
  type        = list(string)
  description = "CIDRs allowed to reach a public API server."
  default     = []

  validation {
    condition     = var.api_server_mode == "private" || length(var.authorized_ip_ranges) > 0
    error_message = "authorized_ip_ranges must contain at least one CIDR when api_server_mode is public."
  }
}

variable "kubernetes_version" {
  type        = string
  description = "AKS version; null uses the regional default."
  default     = null
}

variable "node_vm_size" {
  type        = string
  description = "System node pool VM size (at least 2 vCPU and 4 GiB)."
  default     = "Standard_D2s_v5"
}

variable "node_count" {
  type        = number
  description = "System node pool size."
  default     = 1
}

variable "pod_cidr" {
  type        = string
  description = "Overlay pod CIDR; must not overlap any VNet."
  default     = "192.168.0.0/16"
}

variable "service_cidr" {
  type        = string
  description = "Kubernetes service CIDR; must not overlap any VNet."
  default     = "172.16.0.0/16"
}

variable "dns_service_ip" {
  type        = string
  description = "Cluster DNS service IP inside service_cidr."
  default     = "172.16.0.10"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to every resource."
}
