# ADR-003: Pull requests validate only; plan and gated apply run on `main`, and plan files are never published

- **Status:** Accepted
- **Date:** 2026-11-05

## Context
The repository is public. A pull-request job that could obtain an Azure token would let pull-request code act with the deploy identity's privileges (ADR-006). Plans are sensitive too: a saved plan file stores every value Terraform knows, unencrypted, including the prior state, which after the first apply holds the session hosts' generated local administrator password and the AVD registration token. Workflow logs and artifacts in a public repository are visible to other GitHub users.

## Decision
Pull requests run validation only: `terraform fmt -check`, `validate` and TFLint for every stack, reported through the required `ci-passed` check. These jobs have no Azure access, because no federated credential matches a pull-request subject (ADR-001). After merge, `main` plans each stack under the branch subject. When a plan reports changes (`-detailed-exitcode`), an apply job runs under an environment subject, behind approval for `platform` and `prod`. The apply job re-plans and applies its own saved plan on the same runner, so no plan file is ever uploaded. Logs carry only the human-readable plan, in which Terraform redacts sensitive values and GitHub masks the subscription and tenant IDs.

## Consequences
- Pull-request code cannot act in Azure, whatever it changes.
- Reviewers see no plan on the pull request. The first plan review happens at the approval gate on `main`, and `dev` applies without one. The AVD and AKS deployments each shipped a configuration error that a plan would have shown (see ADR-007), so the operator now runs a local plan with personal credentials before every merge.
- The approved plan and the applied plan are produced separately. The approver checks the apply job's own plan against the one approved, and `concurrency` serializes runs to keep the gap small.
- Failures surface at deploy time and are fixed through a follow-up pull request or a re-run of the failed job, never by hand in the portal.

## Alternatives considered
- **Plan on pull requests with read-only credentials:** the usual design for private repositories; rejected because pull-request code would run with a token and its plan would be posted publicly.
- **Upload the plan as an artifact and apply exactly that file:** guarantees that the approved plan is the applied plan, but publishes sensitive values; rejected.
- **HCP Terraform runs:** keep plans private and add speculative plans on pull requests; rejected to keep the delivery path inside GitHub and Azure.
