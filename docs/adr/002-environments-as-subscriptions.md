# ADR-002: Environments are separate subscriptions under one Corp management group, not separate management groups

- **Status:** Accepted
- **Date:** 2026-11-06

## Context
The AVD workload needs isolated dev and prod environments, and AKS needs a dev environment. Isolation has to cover access, quota, cost and blast radius, but governance should not differ: prod must run under the guardrails that dev has already exercised. Management groups carry policy and RBAC inheritance; subscriptions are the boundary for access, quota, billing and resource limits.

## Decision
Each environment is its own subscription. `sub-ocasio-lz-dev` and `sub-ocasio-lz-prod` both sit in the single `ocasio-corp` management group, and shared services sit in `sub-ocasio-platform` under `ocasio-platform`. Policy is assigned above the environments, at the intermediate root `ocasio` and at `ocasio-corp`, so both environments inherit the same guardrails. Everything that differs between environments lives in code and pipeline configuration: an `env/<environment>.tfvars` file, one state key per environment (`avd-dev.tfstate`, `avd-prod.tfstate`) and one GitHub environment each, where `dev` applies automatically and `prod` waits for approval. The AVD stack selects its subscription with a map lookup on the environment name.

## Consequences
- Prod runs under exactly the policy set that dev exercised; there are no per-environment assignments to drift apart.
- The subscription boundary separates access, quota, cost and blast radius, so a mistake in dev cannot reach prod resources.
- Adding an environment takes one subscription, one tfvars file, one state key and one GitHub environment, with no change to the hierarchy.
- Quota and region access are per subscription and must be checked in each one. These new subscriptions had no DSv5 quota, DSv4 was blocked in East US 2, and West Europe was not accepting new customers, so sizes and regions were validated in both subscriptions before deployment (see ADR-007).
- A policy change reaches dev and prod together. Testing one in isolation would need a separate canary management group hierarchy, which this lab does not have.

## Alternatives considered
- **A management group per environment (`corp-dev`, `corp-prod`):** rejected; duplicates every assignment, lets prod drift from what dev tested, and contradicts Azure landing zone guidance, which models workload archetypes, not environments, as management groups.
- **One subscription with a resource group per environment:** rejected; shared quota, subscription-scope roles that span both environments, and a single blast radius.
- **A tenant per environment:** rejected; duplicates identities, licensing and the deployment trust in ADR-001 for no governance benefit.
