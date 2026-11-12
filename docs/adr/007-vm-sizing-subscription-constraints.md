# ADR-007: Workload VMs use the Dsv6 family with NVMe disks, chosen around the subscriptions' quota and region limits

- **Status:** Accepted
- **Date:** 2026-11-12

## Context
The design specified `Standard_D2s_v5` (2 vCPUs, 8 GiB) for AVD session hosts and AKS nodes. Both landing-zone subscriptions, new on pay-as-you-go, had a DSv5 quota of 0, and an automatic increase request was declined pending manual review. DSv4 had quota but was blocked for these subscriptions in East US 2. Dsv6 had 10 vCPUs of quota in both subscriptions, restricted only for zonal placement, which this build does not use. Dsv6 sizes attach disks only through NVMe and run only Generation 2 images.

## Decision
Both workloads use `Standard_D2s_v6`. The AVD module exposes `disk_controller_type` (`SCSI` or `NVMe`), and both AVD environments set `NVMe`; the Windows 11 multi-session image `win11-24h2-avd` supports both controller types. AKS chooses the disk interface itself, so its node pool sets only `node_vm_size`. Sizes are set per environment in tfvars, so changing them again is configuration, not code.

## Consequences
- Both workloads deployed without waiting on a quota ticket, on newer hardware of the same shape.
- An NVMe-only size fails at the API when any layer drops the controller setting. The first AVD deployment returned `400 InvalidParameter` because the stack never declared or passed `disk_controller_type`, so the module's `SCSI` default reached Azure. The first AKS deployment failed on quota because its node size was still DSv5. A plan would have shown both errors before merge, which is why a local plan now precedes every merge (ADR-003).
- Quota is consumed per family and per subscription, including AKS surge nodes during upgrades, so each subscription keeps headroom for one extra node.
- Image choice is limited to Generation 2 images that support NVMe.

## Alternatives considered
- **Wait for the DSv5 quota ticket:** rejected; it blocked delivery on a manual review for no technical gain.
- **`Standard_D2s_v4`:** rejected; quota was available, but the size is blocked for these subscriptions in East US 2.
- **`Standard_E2bs_v5`:** supports SCSI, so no module change; rejected as a memory-optimized size with twice the memory the workload needs, and kept as the documented fallback.
- **Older families such as DSv3:** rejected; older hardware and a local temporary disk the design does not use.
