#!/usr/bin/env bash
# Usage: scripts/tf-init.sh <root-module-dir> <state-key>
# Example: scripts/tf-init.sh stacks/40-avd avd-dev.tfstate
set -euo pipefail

stack_dir="${1:?usage: tf-init.sh <root-module-dir> <state-key>}"
state_key="${2:?usage: tf-init.sh <root-module-dir> <state-key>}"

: "${TF_VAR_tfstate_resource_group_name:?set TF_VAR_tfstate_resource_group_name}"
: "${TF_VAR_tfstate_storage_account_name:?set TF_VAR_tfstate_storage_account_name}"
: "${TF_VAR_tfstate_container_name:?set TF_VAR_tfstate_container_name}"
: "${ARM_SUBSCRIPTION_ID:?set ARM_SUBSCRIPTION_ID to the platform subscription}"

terraform -chdir="${stack_dir}" init -input=false -reconfigure \
  -backend-config="resource_group_name=${TF_VAR_tfstate_resource_group_name}" \
  -backend-config="storage_account_name=${TF_VAR_tfstate_storage_account_name}" \
  -backend-config="container_name=${TF_VAR_tfstate_container_name}" \
  -backend-config="key=${state_key}" \
  -backend-config="use_azuread_auth=true"
