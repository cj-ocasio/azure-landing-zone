# ADR-006: The lab deploy identity holds Owner at the root management group; production splits it into constrained plan and apply identities

- **Status:** Accepted
- **Date:** 2026-11-05

## Context
One identity deploys every stack (ADR-001): management groups and subscription placement, policy definitions and assignments, a custom role and its assignments, networking across three subscriptions, and workloads that assign roles themselves (Desktop Virtualization User, Virtual Machine User Login, Network Contributor, Private DNS Zone Contributor, Azure Kubernetes Service RBAC Cluster Admin and Azure Kubernetes Service Cluster User Role). Least privilege for that range of operations needs several identities, narrowly scoped roles and role-assignment conditions: more trust plumbing than a single-operator lab needs to demonstrate its design.

## Decision
The lab identity, `id-ocasio-github-deploy`, holds Owner at the `ocasio` management group. The risk is contained by the controls around the role rather than by the role itself: pull requests get no credential (ADR-001, ADR-003), OIDC subjects use GitHub's immutable format, `main` is protected with no administrator bypass, and the `platform` and `prod` environments require approval.

The production design replaces it with:
1. **A plan identity** for the unapproved plan jobs: Reader at the root management group, plus Storage Blob Data Contributor on the state container, because the backend takes a blob lease to lock state even during a plan.
2. **Apply identities per stack or environment**, each holding only the roles its stack needs at the narrowest scope and each behind its environment's approval. Only the RBAC stack's identity can create role definitions.
3. **Constrained role assignment** for workload identities: Role Based Access Control Administrator with a condition that allows only the six roles above, assigned only to service principals and groups.
4. **No standing privilege for people:** Owner and Global Administrator are eligible through Privileged Identity Management, with approval and a time limit, plus two monitored break-glass accounts.

## Consequences
- One identity and four federated credentials keep the trust path simple to build and audit.
- A compromised workflow on `main` would act as Owner over the whole landing zone, including the identity's own federated credentials and the state account, so it could persist its access. Branch protection, environment approvals and immutable subjects are load-bearing controls, not conveniences.
- Plan jobs run without approval yet hold the same Owner token; in the production design they hold Reader.
- Adopting the production design changes bootstrap and the workflows, not the stacks: each job selects its identity's client ID, and each federated credential belongs to the identity that job needs.

## Alternatives considered
- **Contributor plus User Access Administrator:** rejected; User Access Administrator can grant Owner, including to itself, so the split removes nothing.
- **Owner on each subscription instead of the management group:** rejected; management groups and policy definitions sit above subscriptions, so the governance stack would fail.
- **The production design now:** rejected for the lab; it multiplies identities, credentials and workflow wiring, and Privileged Identity Management requires Entra ID P2, which this tenant's licensing does not include.
- **Per-stack identities without conditions:** rejected as a halfway measure; the workload identities would still need unconstrained rights to assign roles.
