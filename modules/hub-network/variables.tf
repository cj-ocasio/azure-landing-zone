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
  description = "Hub VNet address space."
}

variable "subnets" {
  type        = map(string)
  description = "Hub subnets as name => CIDR."
}

variable "private_dns_zones" {
  type        = list(string)
  description = "Private DNS zones hosted centrally in the platform subscription."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to every resource."
}
