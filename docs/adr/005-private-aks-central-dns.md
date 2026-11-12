# ADR-005: The AKS API server is private and registered in the hub's private DNS zone, with its network links created in advance

- **Status:** Accepted
- **Date:** 2026-11-12

## Context
A private AKS cluster has no public API endpoint. Its API server takes a private IP, and its name must resolve through a `privatelink.<region>.azmk8s.io` zone from every network that needs to reach it. AKS can create and own that zone per cluster, or register in an existing one. This landing zone already keeps private DNS in the hub, in the platform subscription, while the cluster runs in `sub-ocasio-lz-dev`. Whichever identity writes the record needs rights on the zone, and AKS needs rights on the spoke network, at the moment the cluster is created.

## Decision
The cluster runs with `private_cluster_enabled = true` and `private_dns_zone_id` set to the hub zone `privatelink.eastus2.azmk8s.io` in `rg-ocasio-dns`. The connectivity stack creates that zone and links it to the hub and all three spokes before any cluster exists. The control plane uses a user-assigned identity that is granted Private DNS Zone Contributor on the zone and Network Contributor on the spoke VNet before the cluster is created, followed by a 120-second wait for role propagation. Operators reach the API through `az aks command invoke`. Authentication is Entra ID with Azure RBAC, and local accounts are disabled.

## Consequences
- One zone serves every private cluster in the region and resolves from every linked network; a DNS resolver in the hub could extend that to on-premises networks without per-cluster work.
- The zone and its links belong to the connectivity stack, so a cluster's lifecycle never changes name resolution for anything else.
- Every first deployment includes a cross-subscription role assignment and a deliberate two-minute wait.
- There is no direct network path to the API from outside Azure. `command invoke` runs each command in a temporary pod, which is slower and suits administration rather than daily development.
- Switching between private and public API modes replaces the cluster.

## Alternatives considered
- **AKS-managed private DNS zone (`System`):** simplest; rejected because the zone lives in the cluster's node resource group, is deleted with the cluster, and resolves only from the cluster's VNet unless more links are added per cluster.
- **Public API server with authorized IP ranges:** convenient for hands-on work and kept as the module's `api_server_mode` toggle; rejected as the default because the endpoint is reachable from the internet.
- **Private cluster with a public FQDN (`None`):** avoids private DNS entirely; rejected because it publishes the API server's private address in public DNS.
- **System-assigned control-plane identity:** rejected; it does not exist until the cluster does, so it cannot be granted the roles that creating the cluster requires.
