#!/usr/bin/env bash
# AzureRM 5.x registers no resource providers by default, so this script is the single source of truth.
set -euo pipefail

: "${TF_VAR_platform_subscription_id:?source scripts/env.local.sh first}"
: "${TF_VAR_lz_dev_subscription_id:?source scripts/env.local.sh first}"
: "${TF_VAR_lz_prod_subscription_id:?source scripts/env.local.sh first}"

subscriptions=(
  "${TF_VAR_platform_subscription_id}"
  "${TF_VAR_lz_dev_subscription_id}"
  "${TF_VAR_lz_prod_subscription_id}"
)

namespaces=(
  Microsoft.Compute
  Microsoft.ContainerService
  Microsoft.DesktopVirtualization
  Microsoft.ManagedIdentity
  Microsoft.Management
  Microsoft.Network
  Microsoft.PolicyInsights
  Microsoft.Storage
)

for sub in "${subscriptions[@]}"; do
  for ns in "${namespaces[@]}"; do
    state="$(az provider show --namespace "${ns}" --subscription "${sub}" --query registrationState -o tsv)"
    if [[ "${state}" == "Registered" ]]; then
      echo "ok           ${ns}  (${sub})"
    else
      echo "registering  ${ns}  (${sub}); was ${state}"
      az provider register --namespace "${ns}" --subscription "${sub}" --wait
    fi
  done
done

echo "Preflight complete."
