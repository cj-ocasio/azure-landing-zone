# ADR-001: GitHub Actions authenticates to Azure with a user-assigned managed identity and OIDC federation

- **Status:** Accepted
- **Date:** 2026-11-04

## Context

The repository is public and its pipeline holds Owner over the landing zone. Any long-lived credential stored in GitHub would be a standing risk: it must be rotated, can be exfiltrated by a malicious workflow change, and cannot be scoped to a branch or an environment.

## Decision

The pipeline uses a user-assigned managed identity with four federated identity credentials: one for `refs/heads/main` (plan jobs) and one each for the `platform`, `dev` and `prod` GitHub environments (apply jobs). GitHub issues a short-lived OIDC token per job; Entra exchanges it for an Azure token only when the token's subject matches a credential exactly. Environments accept deployments only from protected branches, and `platform` and `prod` require approval.

## Consequences

- No secret exists to rotate or leak; subscription and tenant IDs are stored as masked secrets only to keep them out of public logs.
- Pull-request code can never obtain a token, because no credential matches a `pull_request` subject.
- Subjects must match exactly: renaming an environment or branch breaks authentication until the credential is updated in bootstrap.
- The identity holds Owner at the root management group (see ADR-006).

## Alternatives considered

- **Entra app registration with federated credentials:** equivalent security; requires directory permissions and the `azuread` provider in the trust path.
- **Client secret in GitHub secrets:** rejected; a long-lived credential with rotation burden and no branch or environment scoping.
- **Azure DevOps service connection:** viable, but splits code and pipeline evidence across two platforms.
