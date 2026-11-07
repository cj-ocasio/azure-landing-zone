hub_address_space = ["10.0.0.0/22"]

hub_subnets = {
  "snet-shared-services" = "10.0.1.0/24"
}

spokes = {
  "avd-dev" = {
    address_space = ["10.10.0.0/24"]
    subnets = {
      "snet-avd-hosts" = "10.10.0.0/25"
    }
  }
  "avd-prod" = {
    address_space = ["10.20.0.0/24"]
    subnets = {
      "snet-avd-hosts" = "10.20.0.0/25"
    }
  }
  "aks-dev" = {
    address_space = ["10.30.0.0/22"]
    subnets = {
      "snet-aks-nodes" = "10.30.0.0/24"
    }
  }
}
