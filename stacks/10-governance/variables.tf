variable "lz_dev_subscription_id" {
  type        = string
  description = "Corp landing-zone subscription for dev workloads."
}

variable "lz_prod_subscription_id" {
  type        = string
  description = "Corp landing-zone subscription for prod workloads."
}

variable "allowed_locations" {
  type        = list(string)
  description = "Regions resources may be deployed to."
}

variable "required_tag_name" {
  type        = string
  description = "Tag every resource group must carry."
}
