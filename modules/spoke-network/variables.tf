variable "name" {
  type        = string
  description = "Spoke name, for example avd-dev."
}

variable "prefix" {
  type        = string
  description = "Naming prefix."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "address_space" {
  type        = list(string)
  description = "Spoke VNet address space."
}

variable "subnets" {
  type        = map(string)
  description = "Spoke subnets as name => CIDR. Each subnet receives its own NSG."
}

variable "hub" {
  type = object({
    vnet_id             = string
    vnet_name           = string
    resource_group_name = string
  })
  description = "Hub VNet that this spoke peers with."
}

variable "private_dns_zone_ids" {
  type        = map(string)
  description = "Private DNS zones (name => ID) to link to this spoke."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to every resource."
}
