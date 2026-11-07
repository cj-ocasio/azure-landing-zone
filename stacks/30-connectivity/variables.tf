variable "lz_dev_subscription_id" {
  type        = string
  description = "Corp landing-zone subscription for dev workloads."
}

variable "lz_prod_subscription_id" {
  type        = string
  description = "Corp landing-zone subscription for prod workloads."
}

variable "hub_address_space" {
  type        = list(string)
  description = "Hub VNet address space."
}

variable "hub_subnets" {
  type        = map(string)
  description = "Hub subnets as name => CIDR."
}

variable "extra_private_dns_zones" {
  type        = list(string)
  description = "Additional private DNS zones to host in the hub, for future private endpoints."
  default     = []
}

variable "spokes" {
  type = map(object({
    address_space = list(string)
    subnets       = map(string)
  }))
  description = "Spoke definitions keyed by spoke name."

  validation {
    condition     = alltrue([for name in ["avd-dev", "avd-prod", "aks-dev"] : contains(keys(var.spokes), name)])
    error_message = "spokes must define avd-dev, avd-prod and aks-dev."
  }
}
