# ADR-004: Private subnets with explicit egress through NAT Gateway, not default outbound access or a hub firewall

- **Status:** Accepted
- **Date:** 2026-11-07

## Context
Azure has long given virtual machines internet egress through default outbound access: a platform-assigned public IP that the customer does not own, cannot predict and cannot allow-list. Azure has since made private subnets the default for virtual networks created with API versions released after 31 March 2026. Session hosts must still reach the AVD service, Entra ID and Windows Update, and AKS nodes must reach their image registries and Azure endpoints. The Corp management group denies public IPs on network interfaces, and the hub has no firewall.

## Decision
All four subnets set `default_outbound_access_enabled = false`, so nothing gets implicit egress. The AVD module creates a NAT Gateway per environment, with a static Standard public IP, and associates it with the AVD subnet; it is created and destroyed with the workload. AKS uses `outbound_type = "loadBalancer"`, so the cluster's own Standard Load Balancer and its public IP carry node egress. No virtual machine or node has a public IP of its own.

## Consequences
- Egress addresses are owned and stable, so they can be allow-listed, and an AVD session's outbound IP can be checked against the NAT Gateway's public IP.
- Nothing depends on default outbound access, so Azure's change of defaults does not affect the design.
- Egress is translated, not inspected: there is no FQDN filtering, threat intelligence or central egress log. A production landing zone would route `0.0.0.0/0` from the spokes to Azure Firewall in the hub.
- Each AVD environment owns a NAT Gateway that bills by the hour, which is one reason workloads are destroyed between sessions.
- AVD and AKS use different egress mechanisms, and both must be understood when troubleshooting connectivity.

## Alternatives considered
- **Default outbound access:** rejected; implicit, unowned and unpredictable, and no longer the default for new networks.
- **Azure Firewall in the hub with user-defined routes:** the production choice for inspection and central control; rejected for the lab because of its fixed hourly cost and the routing it adds, including AKS's `userDefinedRouting` outbound type and its required egress rules.
- **A public IP per virtual machine:** rejected; denied by Corp policy, and it exposes every host.
- **NAT Gateway for AKS (`userAssignedNATGateway`):** viable and consistent with AVD; deferred, because the cluster's managed load balancer needs no extra resources for a single node.
